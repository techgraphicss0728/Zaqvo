"""
Dashboard user provisioning and lifecycle (super admin only).

Users are added with mobile + role; OTP verification activates the account.
"""
from __future__ import annotations

import math
from datetime import datetime

from bson import ObjectId
from bson.errors import InvalidId
from fastapi import HTTPException

from app.core.role_enums import DashboardRole, is_dashboard_assignable, is_super_admin_role
from app.services.auth_service import AuthService
from app.services.bsnl_admin_sms import send_admin_login_otp_sms
from app.services.otp_service import otp_service
from app.schemas.admin_users import (
    AdminUserCreateSendOtpRequest,
    AdminUserCreateVerifyOtpRequest,
    AdminUserListResponse,
    AdminUserStatusRequest,
    AdminUserSummaryResponse,
    AdminUserUpdateRequest,
)

_SMS_UNAVAILABLE = "Unable to send OTP. Please try again in a few minutes."


class AdminUserService(AuthService):
    async def list_users(self, *, page: int = 1, limit: int = 10) -> AdminUserListResponse:
        col = self._get_users_collection("admin")
        page = max(1, page)
        limit = min(max(1, limit), 100)
        skip = (page - 1) * limit

        total = await col.count_documents({})
        cursor = col.find({}).sort("created_at", -1).skip(skip).limit(limit)
        docs = await cursor.to_list(length=limit)

        return AdminUserListResponse(
            items=[self._to_summary(doc) for doc in docs],
            page=page,
            limit=limit,
            total=total,
            pages=max(1, math.ceil(total / limit)) if total else 1,
        )

    async def create_send_otp(
        self,
        body: AdminUserCreateSendOtpRequest,
        *,
        created_by_admin_id: str,
    ) -> dict:
        """Step 1 — create pending admin and SMS OTP to the new user's mobile."""
        col = self._get_users_collection("admin")
        role = await self._find_role_or_404(body.role_id)

        existing = await col.find_one({"mobile_number": body.mobile_number})
        if existing and existing.get("otp_verified") and existing.get("is_active"):
            raise HTTPException(status_code=409, detail="User with this mobile number already exists")

        if not is_dashboard_assignable(role.get("slug"), is_active=bool(role.get("is_active", True))):
            raise HTTPException(status_code=400, detail="This role cannot be assigned to dashboard users")

        now = datetime.utcnow()
        payload = {
            "name": body.name,
            "mobile_number": body.mobile_number,
            "otp_verified": False,
            "is_active": False,
            "is_super_admin": False,
            "role_id": str(role["_id"]),
            "role_slug": role.get("slug"),
            "role_name": role.get("name"),
            "password_hash": None,
            "created_by": created_by_admin_id,
            "updated_at": now,
        }

        if existing:
            await col.update_one({"_id": existing["_id"]}, {"$set": payload})
            admin_id = existing["_id"]
        else:
            payload["created_at"] = now
            payload["last_login"] = None
            created = await col.insert_one(payload)
            admin_id = created.inserted_id

        code = await otp_service.create_or_update(
            user_id=admin_id,
            role="admin",
            mobile_number=body.mobile_number,
            purpose="provision",
        )
        result = await send_admin_login_otp_sms(body.mobile_number, code)
        if not result.get("success"):
            raise HTTPException(status_code=503, detail=_SMS_UNAVAILABLE)

        return {"message": "OTP sent to mobile number for user verification"}

    async def create_verify_otp(self, body: AdminUserCreateVerifyOtpRequest) -> AdminUserSummaryResponse:
        """Step 2 — verify OTP and activate the provisioned user."""
        col = self._get_users_collection("admin")
        admin_doc = await col.find_one({"mobile_number": body.mobile_number})
        if not admin_doc:
            raise HTTPException(status_code=404, detail="Pending user not found")

        await self._verify_provision_otp(
            mobile_number=body.mobile_number,
            otp=body.otp,
            user_id=admin_doc["_id"],
        )

        now = datetime.utcnow()
        await col.update_one(
            {"_id": admin_doc["_id"]},
            {"$set": {"otp_verified": True, "is_active": True, "updated_at": now}},
        )
        updated = await col.find_one({"_id": admin_doc["_id"]})
        return self._to_summary(updated)

    async def update_user(self, user_id: str, body: AdminUserUpdateRequest) -> AdminUserSummaryResponse:
        col = self._get_users_collection("admin")
        doc = await self._find_admin_or_404(user_id)

        if doc.get("is_super_admin"):
            raise HTTPException(status_code=403, detail="Super admin account cannot be edited here")

        updates: dict = {"updated_at": datetime.utcnow()}
        if body.name is not None:
            updates["name"] = body.name
        if body.role_id is not None:
            role = await self._find_role_or_404(body.role_id)
            if not is_dashboard_assignable(
                role.get("slug"), is_active=bool(role.get("is_active", True))
            ):
                raise HTTPException(status_code=400, detail="This role cannot be assigned to dashboard users")
            updates["role_id"] = str(role["_id"])
            updates["role_slug"] = role.get("slug")
            updates["role_name"] = role.get("name")

        await col.update_one({"_id": doc["_id"]}, {"$set": updates})
        updated = await col.find_one({"_id": doc["_id"]})
        return self._to_summary(updated)

    async def set_user_status(self, user_id: str, body: AdminUserStatusRequest) -> AdminUserSummaryResponse:
        col = self._get_users_collection("admin")
        doc = await self._find_admin_or_404(user_id)

        if doc.get("is_super_admin") and not body.is_active:
            raise HTTPException(status_code=403, detail="Super admin cannot be deactivated")

        await col.update_one(
            {"_id": doc["_id"]},
            {"$set": {"is_active": body.is_active, "updated_at": datetime.utcnow()}},
        )
        updated = await col.find_one({"_id": doc["_id"]})
        return self._to_summary(updated)

    async def _find_admin_or_404(self, user_id: str) -> dict:
        try:
            oid = ObjectId(user_id)
        except InvalidId as exc:
            raise HTTPException(status_code=400, detail="Invalid user id") from exc
        doc = await self._get_users_collection("admin").find_one({"_id": oid})
        if not doc:
            raise HTTPException(status_code=404, detail="User not found")
        return doc

    async def _find_role_or_404(self, role_id: str) -> dict:
        from app.services.role_service import role_service

        return await role_service._find_role_or_404(role_id)

    async def _verify_provision_otp(self, *, mobile_number: str, otp: str, user_id: ObjectId) -> None:
        otp_doc = await otp_service._load_valid_record(
            role="admin",
            mobile_number=mobile_number,
            otp=otp,
            purpose="provision",
        )
        stored_user_id = otp_service._user_id_for_lookup(otp_doc["user_id"])
        if stored_user_id != user_id:
            raise HTTPException(status_code=400, detail="Invalid OTP")

        await otp_service.mark_verified(otp_doc["_id"])

    @staticmethod
    def _to_summary(doc: dict) -> AdminUserSummaryResponse:
        return AdminUserSummaryResponse(
            id=str(doc["_id"]),
            name=doc.get("name", ""),
            mobile_number=doc.get("mobile_number", ""),
            role_id=doc.get("role_id"),
            role_slug=doc.get("role_slug"),
            role_name=doc.get("role_name"),
            is_super_admin=bool(doc.get("is_super_admin", False)),
            is_active=bool(doc.get("is_active", False)),
            otp_verified=bool(doc.get("otp_verified", False)),
            last_login=doc.get("last_login"),
            created_at=doc.get("created_at"),
            updated_at=doc.get("updated_at"),
        )


admin_user_service = AdminUserService()
