"""
Customer mobile login — OTP via BSNL (direct async, no Celery).

New numbers are created automatically; returning users get fresh OTP + timestamps.
Admin/dashboard auth is unchanged (``admin_auth_service``).
"""
from __future__ import annotations

from datetime import datetime

import structlog
from fastapi import BackgroundTasks, HTTPException

from app.core.config import settings
from app.schemas.auth import LoginOTPRequest, OTPVerifyRequest, TokenResponse
from app.services.auth_service import AuthService
from app.services.otp_service import otp_service
from app.services.sms_service import send_otp_sms

logger = structlog.get_logger(__name__)

_SMS_UNAVAILABLE = "Unable to send OTP. Please try again in a few minutes."


class CustomerAuthService(AuthService):
    async def _upsert_customer_for_login(self, mobile_number: str):
        """Create a new customer or refresh timestamps for an existing one."""
        users_col = self._get_users_collection("customer")
        now = datetime.utcnow()
        existing = await users_col.find_one({"mobile_number": mobile_number})

        if existing:
            await users_col.update_one(
                {"_id": existing["_id"]},
                {"$set": {"updated_at": now, "last_otp_sent_at": now}},
            )
            return existing["_id"], False

        result = await users_col.insert_one(
            {
                "mobile_number": mobile_number,
                "name": None,
                "photo": None,
                "otp_verified": False,
                "is_active": True,
                "password_hash": None,
                "address_id": None,
                "created_at": now,
                "updated_at": now,
                "last_otp_sent_at": now,
                "last_login": None,
            }
        )
        return result.inserted_id, True

    async def _send_customer_login_otp_sms(self, mobile_number: str, otp: str) -> dict:
        """Send customer OTP through BSNL without blocking on Celery/Redis."""
        if settings.APP_ENV == "development" and not settings.BSNL_AUTH_TOKEN.strip():
            suffix = mobile_number[-4:] if len(mobile_number) >= 4 else mobile_number
            logger.warning(
                "customer_login_otp_dev_mode",
                mobile_suffix=suffix,
                otp=otp,
                hint="Set BSNL_AUTH_TOKEN in .env to send real SMS",
            )
            return {
                "success": True,
                "message": "OTP logged in server console (development mode)",
                "dev_mode": True,
            }

        return await send_otp_sms(mobile_number, otp)

    async def _dispatch_customer_login_otp_sms(self, mobile_number: str, otp: str) -> None:
        """Background worker — logs failures; never blocks the HTTP response."""
        result = await self._send_customer_login_otp_sms(mobile_number, otp)
        if not result.get("success"):
            logger.warning(
                "customer_login_sms_background_failed",
                mobile_suffix=mobile_number[-4:],
                detail=result.get("message"),
                error=result.get("error"),
            )

    async def login_send_otp(
        self,
        body: LoginOTPRequest,
        background_tasks: BackgroundTasks,
    ) -> dict:
        """
        Step 1 — upsert customer, persist OTP, return immediately.

        SMS is queued in a background task so slow BSNL responses never block the app.
        In development without BSNL token, OTP is logged synchronously to the API terminal.
        """
        user_id, _created = await self._upsert_customer_for_login(body.mobile_number)

        code = await otp_service.create_or_update(
            user_id=user_id,
            role="customer",
            mobile_number=body.mobile_number,
            purpose="login",
        )

        if settings.APP_ENV == "development" and not settings.BSNL_AUTH_TOKEN.strip():
            result = await self._send_customer_login_otp_sms(body.mobile_number, code)
            return {
                "message": result.get("message", "OTP sent to mobile number"),
                "dev_mode": bool(result.get("dev_mode")),
            }

        background_tasks.add_task(
            self._dispatch_customer_login_otp_sms,
            body.mobile_number,
            code,
        )
        return {"message": "OTP sent to mobile number", "dev_mode": False}

    async def login_verify_otp(self, body: OTPVerifyRequest) -> TokenResponse:
        """Step 2 — verify OTP, issue JWT, record last login."""
        users_col = self._get_users_collection("customer")
        tokens = await self._verify_otp_for_role(
            role="customer",
            body=body,
            purpose="login",
        )

        now = datetime.utcnow()
        await users_col.update_one(
            {"mobile_number": body.mobile_number},
            {"$set": {"last_login": now, "updated_at": now}},
        )
        return tokens


customer_auth_service = CustomerAuthService()
