"""
Admin authentication — OTP-only dashboard login.

Users must be provisioned by a super admin before they can sign in.
"""
from __future__ import annotations

from datetime import datetime

from fastapi import HTTPException

from app.schemas.auth import (
    AdminAuthResponse,
    AdminAuthUser,
    LoginOTPRequest,
    OTPVerifyRequest,
)
from app.services.auth_service import AuthService
from app.services.bsnl_admin_sms import send_admin_login_otp_sms
from app.services.otp_service import otp_service
from app.services.permission_service import permission_service

_SMS_UNAVAILABLE = "Unable to send OTP. Please try again in a few minutes."
_LOGIN_DENIED = "Mobile number not registered or account is inactive"


class AdminAuthService(AuthService):
    async def _admin_user_from_doc(self, user_doc: dict) -> AdminAuthUser:
        permissions = await permission_service.resolve_for_admin(user_doc)
        return AdminAuthUser(
            id=str(user_doc["_id"]),
            name=user_doc.get("name", ""),
            mobile_number=user_doc.get("mobile_number", ""),
            is_super_admin=bool(user_doc.get("is_super_admin", False)),
            role_id=user_doc.get("role_id"),
            role_slug=user_doc.get("role_slug"),
            role_name=user_doc.get("role_name"),
            permissions=permissions,
        )

    async def _find_active_admin_by_mobile(self, mobile_number: str) -> dict | None:
        """
        Find a login-eligible admin.

        Legacy documents may omit ``is_active`` — treat missing as active unless explicitly ``false``.
        """
        doc = await self._get_users_collection("admin").find_one(
            {
                "mobile_number": mobile_number,
                "otp_verified": True,
            }
        )
        if not doc:
            return None
        if doc.get("is_active") is False:
            return None
        return doc

    async def login_send_otp(self, body: LoginOTPRequest) -> dict:
        """Step 1 — mobile-only login; OTP sent to registered active users."""
        admin_doc = await self._find_active_admin_by_mobile(body.mobile_number)
        if not admin_doc:
            raise HTTPException(status_code=401, detail=_LOGIN_DENIED)

        code = await otp_service.create_or_update(
            user_id=admin_doc["_id"],
            role="admin",
            mobile_number=body.mobile_number,
            purpose="login",
        )
        result = await send_admin_login_otp_sms(body.mobile_number, code)
        if not result.get("success"):
            raise HTTPException(status_code=503, detail=_SMS_UNAVAILABLE)

        return {
            "message": result.get("message", "OTP sent to mobile number"),
            "dev_mode": bool(result.get("dev_mode")),
        }

    async def login_verify_otp(self, body: OTPVerifyRequest) -> AdminAuthResponse:
        """Step 2 — verify OTP and issue session with role permissions."""
        users_col = self._get_users_collection("admin")
        admin_doc = await self._find_active_admin_by_mobile(body.mobile_number)
        if not admin_doc:
            raise HTTPException(status_code=401, detail=_LOGIN_DENIED)

        tokens = await otp_service.verify_and_issue_tokens(
            role="admin",
            mobile_number=body.mobile_number,
            otp=body.otp,
            purpose="login",
            users_collection=users_col,
        )

        now = datetime.utcnow()
        await users_col.update_one(
            {"_id": admin_doc["_id"]},
            {"$set": {"last_login": now, "updated_at": now}},
        )
        admin_doc = await users_col.find_one({"_id": admin_doc["_id"]})
        if not admin_doc or admin_doc.get("is_active") is False:
            raise HTTPException(status_code=401, detail=_LOGIN_DENIED)

        admin_user = await self._admin_user_from_doc(admin_doc)
        return AdminAuthResponse(
            access_token=tokens.access_token,
            refresh_token=tokens.refresh_token,
            token_type=tokens.token_type,
            admin=admin_user,
        )


admin_auth_service = AdminAuthService()
