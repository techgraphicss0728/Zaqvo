"""
Role CRUD and permission matrix management.

System roles are seeded on startup; super admin may create custom roles with any name.
"""
from __future__ import annotations

import math
import re
from datetime import datetime

from bson import ObjectId
from bson.errors import InvalidId
from fastapi import HTTPException

from app.core.permissions_catalog import empty_page_permissions, full_page_permissions
from app.core.role_enums import (
    DASHBOARD_HIDDEN_ROLE_SLUGS,
    ROLE_DEFINITIONS,
    DashboardRole,
    is_dashboard_assignable,
    is_super_admin_role,
)
from app.db.mongodb import get_db
from app.schemas.permissions import PermissionCatalogResponse
from app.schemas.roles import (
    RoleCreateRequest,
    RoleDetailResponse,
    RoleListResponse,
    RolePermissionsUpdateRequest,
    RoleSummaryResponse,
    RoleUpdateRequest,
)


def _slugify_role_name(name: str) -> str:
    slug = re.sub(r"[^a-zA-Z0-9]+", "_", name.strip()).strip("_").upper()
    if not slug:
        raise HTTPException(status_code=400, detail="Role name must contain letters or numbers")
    return slug[:64]


class RoleService:
    COLLECTION = "roles"

    def _get_db(self):
        db = get_db()
        if db is None:
            raise HTTPException(status_code=500, detail="Database not initialized")
        return db

    @staticmethod
    def _to_summary(doc: dict) -> RoleSummaryResponse:
        return RoleSummaryResponse(
            id=str(doc["_id"]),
            name=doc.get("name", ""),
            slug=doc.get("slug", ""),
            description=doc.get("description", ""),
            is_system=bool(doc.get("is_system", False)),
            is_active=bool(doc.get("is_active", True)),
        )

    @staticmethod
    def _to_detail(doc: dict) -> RoleDetailResponse:
        summary = RoleService._to_summary(doc)
        return RoleDetailResponse(
            **summary.model_dump(),
            permissions=doc.get("permissions") or {},
            created_at=doc.get("created_at"),
            updated_at=doc.get("updated_at"),
        )

    def _dashboard_roles_filter(self) -> dict:
        return {"slug": {"$nin": list(DASHBOARD_HIDDEN_ROLE_SLUGS)}}

    async def get_permissions_catalog(self) -> PermissionCatalogResponse:
        return PermissionCatalogResponse()

    async def list_roles(self) -> list[RoleSummaryResponse]:
        cursor = (
            self._get_db()[self.COLLECTION]
            .find(self._dashboard_roles_filter())
            .sort("name", 1)
        )
        docs = await cursor.to_list(length=500)
        return [self._to_summary(doc) for doc in docs]

    async def list_roles_paginated(self, *, page: int = 1, limit: int = 10) -> RoleListResponse:
        col = self._get_db()[self.COLLECTION]
        page = max(1, page)
        limit = min(max(1, limit), 100)
        skip = (page - 1) * limit
        query = self._dashboard_roles_filter()

        total = await col.count_documents(query)
        cursor = col.find(query).sort("name", 1).skip(skip).limit(limit)
        docs = await cursor.to_list(length=limit)

        return RoleListResponse(
            items=[self._to_summary(doc) for doc in docs],
            page=page,
            limit=limit,
            total=total,
            pages=max(1, math.ceil(total / limit)) if total else 1,
        )

    async def list_assignable_roles(self) -> list[RoleSummaryResponse]:
        """Roles that super admin can assign when provisioning dashboard users."""
        result: list[RoleSummaryResponse] = []
        for role in await self.list_roles():
            if is_dashboard_assignable(role.slug, is_active=role.is_active):
                result.append(role)
        return result

    async def get_role(self, role_id: str) -> RoleDetailResponse:
        doc = await self._find_role_or_404(role_id)
        return self._to_detail(doc)

    async def get_role_by_slug(self, slug: str) -> dict | None:
        return await self._get_db()[self.COLLECTION].find_one({"slug": slug})

    async def _find_role_or_404(self, role_id: str) -> dict:
        try:
            oid = ObjectId(role_id)
        except InvalidId as exc:
            raise HTTPException(status_code=400, detail="Invalid role id") from exc
        doc = await self._get_db()[self.COLLECTION].find_one({"_id": oid})
        if not doc:
            raise HTTPException(status_code=404, detail="Role not found")
        return doc

    async def _ensure_unique_slug(self, base_slug: str, *, exclude_id: ObjectId | None = None) -> str:
        col = self._get_db()[self.COLLECTION]
        slug = base_slug
        suffix = 2
        while True:
            query: dict = {"slug": slug}
            if exclude_id:
                query["_id"] = {"$ne": exclude_id}
            existing = await col.find_one(query)
            if not existing:
                return slug
            slug = f"{base_slug}_{suffix}"
            suffix += 1

    async def create_role(self, body: RoleCreateRequest) -> RoleDetailResponse:
        col = self._get_db()[self.COLLECTION]
        base_slug = _slugify_role_name(body.name)
        slug = await self._ensure_unique_slug(base_slug)

        now = datetime.utcnow()
        doc = {
            "name": body.name.strip(),
            "slug": slug,
            "description": body.description.strip(),
            "is_system": False,
            "is_active": True,
            "permissions": empty_page_permissions(),
            "created_at": now,
            "updated_at": now,
        }
        created = await col.insert_one(doc)
        saved = await col.find_one({"_id": created.inserted_id})
        return self._to_detail(saved)

    async def update_role(self, role_id: str, body: RoleUpdateRequest) -> RoleDetailResponse:
        doc = await self._find_role_or_404(role_id)
        if is_super_admin_role(doc.get("slug")):
            raise HTTPException(status_code=403, detail="Super admin role cannot be modified")

        updates: dict = {"updated_at": datetime.utcnow()}

        if body.name is not None:
            updates["name"] = body.name.strip()
        if body.description is not None:
            updates["description"] = body.description.strip()
        if body.is_active is not None:
            updates["is_active"] = body.is_active
            if not body.is_active:
                in_use = await self._get_db()["admins"].count_documents(
                    {"role_id": str(doc["_id"]), "is_active": True}
                )
                if in_use:
                    raise HTTPException(
                        status_code=409,
                        detail="Cannot deactivate a role assigned to active users",
                    )

        await self._get_db()[self.COLLECTION].update_one({"_id": doc["_id"]}, {"$set": updates})
        updated = await self._get_db()[self.COLLECTION].find_one({"_id": doc["_id"]})
        return self._to_detail(updated)

    async def delete_role(self, role_id: str) -> None:
        doc = await self._find_role_or_404(role_id)
        if is_super_admin_role(doc.get("slug")):
            raise HTTPException(status_code=403, detail="Super admin role cannot be deleted")
        if doc.get("is_system"):
            raise HTTPException(status_code=403, detail="System roles cannot be deleted")

        in_use = await self._get_db()["admins"].count_documents({"role_id": str(doc["_id"])})
        if in_use:
            raise HTTPException(status_code=409, detail="Role is assigned to users and cannot be deleted")

        await self._get_db()[self.COLLECTION].delete_one({"_id": doc["_id"]})

    async def update_permissions(
        self,
        role_id: str,
        body: RolePermissionsUpdateRequest,
    ) -> RoleDetailResponse:
        doc = await self._find_role_or_404(role_id)
        if is_super_admin_role(doc.get("slug")):
            raise HTTPException(status_code=403, detail="Super admin role permissions cannot be changed")

        await self._get_db()[self.COLLECTION].update_one(
            {"_id": doc["_id"]},
            {
                "$set": {
                    "permissions": body.permissions,
                    "updated_at": datetime.utcnow(),
                }
            },
        )
        updated = await self._get_db()[self.COLLECTION].find_one({"_id": doc["_id"]})
        return self._to_detail(updated)

    async def seed_default_roles(self) -> None:
        """Idempotent seed for all ``DashboardRole`` enum values."""
        col = self._get_db()[self.COLLECTION]
        now = datetime.utcnow()

        for role_enum in DashboardRole:
            meta = ROLE_DEFINITIONS[role_enum]
            existing = await col.find_one({"slug": role_enum.value})
            if existing:
                await col.update_one(
                    {"_id": existing["_id"]},
                    {
                        "$set": {
                            "name": meta["label"],
                            "description": meta["description"],
                            "is_system": True,
                            "is_active": True,
                            "updated_at": now,
                        }
                    },
                )
                continue
            await col.insert_one(
                {
                    "slug": role_enum.value,
                    "name": meta["label"],
                    "description": meta["description"],
                    "is_system": True,
                    "is_active": True,
                    "permissions": _default_permissions_for(role_enum),
                    "created_at": now,
                    "updated_at": now,
                }
            )

    async def migrate_legacy_roles(self) -> None:
        """Rename deprecated SUPERVISOR slug and backfill ``is_active`` on roles."""
        col = self._get_db()[self.COLLECTION]
        now = datetime.utcnow()

        await col.update_many({"is_active": {"$exists": False}}, {"$set": {"is_active": True, "updated_at": now}})

        supervisor = await col.find_one({"slug": "SUPERVISOR"})
        if not supervisor:
            return

        support = await col.find_one({"slug": DashboardRole.SUPPORT_EXECUTIVE.value})
        support_id = str(support["_id"]) if support else str(supervisor["_id"])

        if support and support["_id"] != supervisor["_id"]:
            await self._get_db()["admins"].update_many(
                {"role_id": str(supervisor["_id"])},
                {
                    "$set": {
                        "role_id": support_id,
                        "role_slug": DashboardRole.SUPPORT_EXECUTIVE.value,
                        "role_name": support.get("name"),
                        "updated_at": now,
                    }
                },
            )
            await self._get_db()["admins"].update_many(
                {"role_slug": "SUPERVISOR"},
                {
                    "$set": {
                        "role_id": support_id,
                        "role_slug": DashboardRole.SUPPORT_EXECUTIVE.value,
                        "role_name": support.get("name"),
                        "updated_at": now,
                    }
                },
            )
            await col.delete_one({"_id": supervisor["_id"]})
        else:
            meta = ROLE_DEFINITIONS[DashboardRole.SUPPORT_EXECUTIVE]
            await col.update_one(
                {"_id": supervisor["_id"]},
                {
                    "$set": {
                        "slug": DashboardRole.SUPPORT_EXECUTIVE.value,
                        "name": meta["label"],
                        "description": meta["description"],
                        "is_system": True,
                        "is_active": True,
                        "updated_at": now,
                    }
                },
            )
            await self._get_db()["admins"].update_many(
                {"role_slug": "SUPERVISOR"},
                {
                    "$set": {
                        "role_slug": DashboardRole.SUPPORT_EXECUTIVE.value,
                        "role_name": meta["label"],
                        "updated_at": now,
                    }
                },
            )


def _default_permissions_for(role: DashboardRole) -> dict:
    if role == DashboardRole.SUPER_ADMIN:
        return full_page_permissions()

    if role == DashboardRole.ADMIN:
        return _admin_default_permissions()

    if role == DashboardRole.STORE_MANAGER:
        return _grant_pages(
            {"home", "orders", "catalog", "products", "coupons", "payments", "collections"},
            actions=("view", "add", "edit"),
        )

    if role == DashboardRole.INVENTORY_MANAGER:
        return _grant_pages(
            {"catalog", "products", "collections"},
            actions=("view", "add", "edit", "delete"),
        )

    if role == DashboardRole.DELIVERY_MANAGER:
        return _grant_pages(
            {"orders", "drivers", "approvals"},
            actions=("view", "add", "edit"),
            buttons={"orders": ["assign_driver", "cancel"], "drivers": ["verify"], "approvals": ["approve", "reject"]},
        )

    if role == DashboardRole.SUPPORT_EXECUTIVE:
        return _grant_pages(
            {"home", "orders", "approvals", "ratings", "feedbacks"},
            actions=("view", "edit"),
            buttons={"approvals": ["approve", "reject"], "feedbacks": ["reply"]},
        )

    if role == DashboardRole.FINANCE_MANAGER:
        return _grant_pages(
            {"home", "payments", "collections", "coupons"},
            actions=("view", "add", "edit"),
        )

    # CUSTOMER — no dashboard access by default
    return empty_page_permissions()


def _grant_pages(
    page_keys: set[str],
    *,
    actions: tuple[str, ...] = ("view",),
    buttons: dict[str, list[str]] | None = None,
) -> dict:
    perms = empty_page_permissions()
    for key in page_keys:
        if key not in perms:
            continue
        for action in actions:
            perms[key][action] = True
        if buttons and key in buttons:
            for btn in buttons[key]:
                if btn in perms[key]["buttons"]:
                    perms[key]["buttons"][btn] = True
    return perms


def _admin_default_permissions() -> dict:
    perms = empty_page_permissions()
    operational = {
        "home",
        "payments",
        "collections",
        "orders",
        "catalog",
        "products",
        "drivers",
        "approvals",
        "ratings",
        "feedbacks",
        "coupons",
    }
    for key in operational:
        perms[key]["view"] = True
        perms[key]["add"] = True
        perms[key]["edit"] = True
    return perms


role_service = RoleService()
