"""Resolve effective permissions for an admin user."""
from __future__ import annotations

from typing import Any

from bson import ObjectId
from bson.errors import InvalidId
from fastapi import HTTPException

from app.core.permissions_catalog import full_page_permissions
from app.db.mongodb import get_db


class PermissionService:
    ROLES_COLLECTION = "roles"

    def _get_db(self):
        db = get_db()
        if db is None:
            raise HTTPException(status_code=500, detail="Database not initialized")
        return db

    async def get_role_permissions(self, role_id: str | None) -> dict[str, Any]:
        if not role_id:
            return {}
        try:
            oid = ObjectId(role_id)
        except InvalidId:
            return {}

        doc = await self._get_db()[self.ROLES_COLLECTION].find_one({"_id": oid})
        if not doc:
            return {}
        return doc.get("permissions") or {}

    async def resolve_for_admin(self, admin_doc: dict) -> dict[str, Any]:
        """Super admins receive full access; others inherit role permissions."""
        if admin_doc.get("is_super_admin"):
            return full_page_permissions()
        return await self.get_role_permissions(admin_doc.get("role_id"))

    def has_permission(
        self,
        permissions: dict[str, Any],
        *,
        page_key: str,
        action: str = "view",
        button_key: str | None = None,
    ) -> bool:
        if not permissions:
            return False
        page = permissions.get(page_key)
        if not page:
            return False
        if button_key:
            buttons = page.get("buttons") or {}
            return bool(buttons.get(button_key))
        return bool(page.get(action))


permission_service = PermissionService()
