"""
Customer and driver authentication.

Admin flows live in ``admin_auth_service``; OTP persistence in ``otp_service``.
Routers should only delegate to these services — no business logic in endpoints.
"""
from __future__ import annotations

from datetime import datetime
from typing import Literal, cast

from bson import ObjectId
from bson.errors import InvalidId
from fastapi import HTTPException
from motor.motor_asyncio import AsyncIOMotorDatabase

from app.core.security import decode_token
from app.db.mongodb import get_db
from app.schemas.auth import (
    AdminSignupRequest,
    CustomerSignupRequest,
    DriverSignupRequest,
    LoginOTPRequest,
    OTPVerifyRequest,
    RefreshTokenRequest,
    RoleLiteral,
    TokenResponse,
)
from app.services.otp_service import otp_service


class AuthService:
    """Shared DB helpers and customer/driver auth. Subclassed by ``AdminAuthService``."""

    def _get_db_or_fail(self) -> AsyncIOMotorDatabase:
        db = get_db()
        if db is None:
            raise HTTPException(status_code=500, detail="Database not initialized")
        return db

    def _get_users_collection(self, role: RoleLiteral):
        db = self._get_db_or_fail()
        if role == "customer":
            return db["customers"]
        if role == "driver":
            return db["drivers"]
        if role == "admin":
            return db["admins"]
        raise ValueError("Invalid role")

    async def _send_otp_or_fail(self, mobile_number: str, code: str) -> None:
        """Queue OTP SMS via Celery (customer/driver signup and login)."""
        from app.workers.notifications import send_otp_sms_task

        try:
            send_otp_sms_task.delay(mobile_number, code)
        except Exception as exc:
            raise HTTPException(
                status_code=503,
                detail="Unable to send OTP. Please try again in a few minutes.",
            ) from exc

    async def _create_or_get_user_for_signup(
        self,
        role: RoleLiteral,
        mobile_number: str,
        payload: CustomerSignupRequest | DriverSignupRequest | AdminSignupRequest,
    ) -> ObjectId:
        users_col = self._get_users_collection(role)
        existing = await users_col.find_one({"mobile_number": mobile_number})
        if existing and existing.get("otp_verified"):
            raise HTTPException(status_code=400, detail="User already registered")

        now = datetime.utcnow()
        base_doc: dict = {
            "mobile_number": mobile_number,
            "otp_verified": False,
            "created_at": now,
            "updated_at": now,
        }

        if role == "customer":
            customer_payload = cast(CustomerSignupRequest, payload)
            base_doc.update(
                {
                    "name": customer_payload.name,
                    "photo": customer_payload.photo,
                    "is_active": True,
                    "password_hash": None,
                    "address_id": None,
                }
            )
        elif role == "driver":
            driver_payload = cast(DriverSignupRequest, payload)
            base_doc.update(
                {
                    "name": driver_payload.name,
                    "photo": driver_payload.photo,
                    "license_number": driver_payload.license_number,
                    "vehicle_type": driver_payload.vehicle_type,
                    "vehicle_number": driver_payload.vehicle_number,
                    "status": "offline",
                    "is_verified": False,
                    "is_active": True,
                    "rating": 0.0,
                    "total_deliveries": 0,
                    "last_online": None,
                }
            )
        else:
            admin_payload = cast(AdminSignupRequest, payload)
            base_doc.update(
                {
                    "name": admin_payload.name,
                    "is_super_admin": False,
                    "password_hash": None,
                    "last_login": None,
                }
            )

        if existing:
            await users_col.update_one({"_id": existing["_id"]}, {"$set": base_doc})
            return existing["_id"]

        result = await users_col.insert_one(base_doc)
        return result.inserted_id

    async def _signup_send_otp(
        self,
        role: RoleLiteral,
        body: CustomerSignupRequest | DriverSignupRequest | AdminSignupRequest,
    ) -> dict:
        user_id = await self._create_or_get_user_for_signup(
            role=role,
            mobile_number=body.mobile_number,
            payload=body,
        )
        code = await otp_service.create_or_update(
            user_id=user_id,
            role=role,
            mobile_number=body.mobile_number,
            purpose="signup",
        )
        await self._send_otp_or_fail(body.mobile_number, code)
        return {"message": "OTP sent to mobile number"}

    async def _login_send_otp(
        self,
        role: RoleLiteral,
        body: LoginOTPRequest,
        *,
        extra_query: dict | None = None,
        not_found_detail: str,
    ) -> dict:
        users_col = self._get_users_collection(role)
        query = {"mobile_number": body.mobile_number, "otp_verified": True}
        if extra_query:
            query.update(extra_query)
        user = await users_col.find_one(query)
        if not user:
            raise HTTPException(status_code=404, detail=not_found_detail)

        code = await otp_service.create_or_update(
            user_id=user["_id"],
            role=role,
            mobile_number=body.mobile_number,
            purpose="login",
        )
        await self._send_otp_or_fail(body.mobile_number, code)
        return {"message": "OTP sent to mobile number"}

    async def _verify_otp_for_role(
        self,
        role: RoleLiteral,
        body: OTPVerifyRequest,
        *,
        purpose: Literal["signup", "login"],
    ) -> TokenResponse:
        return await otp_service.verify_and_issue_tokens(
            role=role,
            mobile_number=body.mobile_number,
            otp=body.otp,
            purpose=purpose,
            users_collection=self._get_users_collection(role),
        )

    async def customer_signup_send_otp(self, body: CustomerSignupRequest) -> dict:
        return await self._signup_send_otp(role="customer", body=body)

    async def customer_signup_verify_otp(self, body: OTPVerifyRequest) -> TokenResponse:
        return await self._verify_otp_for_role(role="customer", body=body, purpose="signup")

    async def driver_signup_send_otp(self, body: DriverSignupRequest) -> dict:
        return await self._signup_send_otp(role="driver", body=body)

    async def driver_signup_verify_otp(self, body: OTPVerifyRequest) -> TokenResponse:
        return await self._verify_otp_for_role(role="driver", body=body, purpose="signup")

    async def admin_signup_send_otp(self, body: AdminSignupRequest) -> dict:
        return await self._signup_send_otp(role="admin", body=body)

    async def admin_signup_verify_otp(self, body: OTPVerifyRequest) -> TokenResponse:
        return await self._verify_otp_for_role(role="admin", body=body, purpose="signup")

    async def customer_login_send_otp(self, body: LoginOTPRequest) -> dict:
        return await self._login_send_otp(
            role="customer",
            body=body,
            not_found_detail="Customer not found or not verified",
        )

    async def customer_login_verify_otp(self, body: OTPVerifyRequest) -> TokenResponse:
        return await self._verify_otp_for_role(role="customer", body=body, purpose="login")

    async def driver_login_send_otp(self, body: LoginOTPRequest) -> dict:
        return await self._login_send_otp(
            role="driver",
            body=body,
            extra_query={"is_active": True},
            not_found_detail="Driver not found or not active/verified",
        )

    async def driver_login_verify_otp(self, body: OTPVerifyRequest) -> TokenResponse:
        return await self._verify_otp_for_role(role="driver", body=body, purpose="login")

    async def refresh_tokens(self, body: RefreshTokenRequest) -> TokenResponse:
        """Exchange a valid refresh JWT for new access + refresh tokens (rotation)."""
        if not body.refresh_token:
            raise HTTPException(status_code=400, detail="Refresh token is required")

        payload = decode_token(body.refresh_token)
        if not payload or payload.get("type") != "refresh":
            raise HTTPException(status_code=401, detail="Invalid or expired refresh token")

        role = payload.get("role")
        sub = payload.get("sub")
        if role not in ("customer", "driver", "admin") or not sub:
            raise HTTPException(status_code=401, detail="Invalid refresh token payload")

        try:
            user_id = ObjectId(sub)
        except InvalidId as exc:
            raise HTTPException(status_code=401, detail="Invalid refresh token subject") from exc

        users_col = self._get_users_collection(role)
        user_doc = await users_col.find_one({"_id": user_id})
        if not user_doc:
            raise HTTPException(status_code=401, detail="User no longer exists")

        if role == "customer" and not user_doc.get("otp_verified"):
            raise HTTPException(status_code=401, detail="Session invalid")
        if role == "driver":
            if not user_doc.get("otp_verified") or not user_doc.get("is_active", True):
                raise HTTPException(status_code=403, detail="Driver session invalid")
        if role == "admin" and not user_doc.get("otp_verified"):
            raise HTTPException(status_code=401, detail="Session invalid")

        from app.core.security import create_access_token, create_refresh_token

        is_super_admin = bool(user_doc.get("is_super_admin", False)) if role == "admin" else False
        return TokenResponse(
            access_token=create_access_token(subject=sub, role=role, is_super_admin=is_super_admin),
            refresh_token=create_refresh_token(subject=sub, role=role, is_super_admin=is_super_admin),
        )


auth_service = AuthService()
