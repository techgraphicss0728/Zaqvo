"""OTP lifecycle — generate, persist, verify. Shared by customer, driver, and admin flows."""
from __future__ import annotations

import random
from datetime import datetime, timedelta

from bson import ObjectId
from fastapi import HTTPException
from motor.motor_asyncio import AsyncIOMotorDatabase

from app.core.config import settings
from app.core.security import create_access_token, create_refresh_token
from app.db.mongodb import get_db
from app.models.otp import OTPS_COLLECTION, OtpPurpose
from app.schemas.auth import RoleLiteral, TokenResponse


class OtpService:
    """Central OTP store and verification. TTL is driven by ``settings.OTP_TTL_MINUTES``."""

    @staticmethod
    def _get_db_or_fail() -> AsyncIOMotorDatabase:
        db = get_db()
        if db is None:
            raise HTTPException(status_code=500, detail="Database not initialized")
        return db

    def _get_otp_collection(self):
        return self._get_db_or_fail()[OTPS_COLLECTION]

    @staticmethod
    def generate_code() -> str:
        """Six-digit numeric OTP."""
        return f"{random.randint(0, 999999):06d}"

    @staticmethod
    def _expires_at(*, ttl_minutes: int | None = None) -> datetime:
        minutes = ttl_minutes if ttl_minutes is not None else settings.OTP_TTL_MINUTES
        return datetime.utcnow() + timedelta(minutes=minutes)

    @staticmethod
    def _user_id_query(user_id: ObjectId | str) -> str:
        """Normalize user_id for OTP collection storage and lookups."""
        return str(user_id)

    @staticmethod
    def _user_id_for_lookup(user_id: ObjectId | str) -> ObjectId:
        """Resolve stored user_id back to ObjectId for user collection queries."""
        if isinstance(user_id, ObjectId):
            return user_id
        return ObjectId(user_id)

    async def create_or_update(
        self,
        *,
        user_id: ObjectId,
        role: RoleLiteral,
        mobile_number: str,
        purpose: OtpPurpose,
        ttl_minutes: int | None = None,
    ) -> str:
        """Upsert OTP for a user+purpose pair and return the plaintext code."""
        code = self.generate_code()
        user_id_str = self._user_id_query(user_id)
        filter_doc = {
            "mobile_number": mobile_number,
            "role": role,
            "purpose": purpose,
        }
        now = datetime.utcnow()
        existing = await self._get_otp_collection().find_one(
            filter_doc,
            sort=[("updated_at", -1)],
        )
        created_at = existing.get("created_at", now) if existing else now

        # One OTP row per mobile+role+purpose (cleans legacy duplicates e.g. ObjectId vs str user_id).
        await self._get_otp_collection().delete_many(filter_doc)
        await self._get_otp_collection().insert_one(
            {
                **filter_doc,
                "user_id": user_id_str,
                "code": code,
                "expires_at": self._expires_at(ttl_minutes=ttl_minutes),
                "verified": False,
                "created_at": created_at,
                "updated_at": now,
            }
        )
        return code

    async def _load_valid_record(
        self,
        *,
        role: RoleLiteral,
        mobile_number: str,
        otp: str,
        purpose: OtpPurpose,
    ) -> dict:
        """Return OTP document or raise HTTP 400 with a safe client message."""
        otp_doc = await self._get_otp_collection().find_one(
            {
                "mobile_number": mobile_number,
                "role": role,
                "purpose": purpose,
                "code": otp,
            },
            sort=[("updated_at", -1)],
        )
        if not otp_doc:
            raise HTTPException(status_code=400, detail="Invalid OTP")

        expires_at = otp_doc.get("expires_at")
        if expires_at and expires_at < datetime.utcnow():
            raise HTTPException(status_code=400, detail="OTP expired")

        user_id = otp_doc.get("user_id")
        if not user_id:
            raise HTTPException(status_code=400, detail="Invalid OTP")

        return otp_doc

    async def mark_verified(self, otp_doc_id: ObjectId) -> None:
        await self._get_otp_collection().update_one(
            {"_id": otp_doc_id},
            {"$set": {"verified": True, "verified_at": datetime.utcnow()}},
        )

    async def verify_and_issue_tokens(
        self,
        *,
        role: RoleLiteral,
        mobile_number: str,
        otp: str,
        purpose: OtpPurpose,
        users_collection,
    ) -> TokenResponse:
        """
        Validate OTP, mark user as verified, invalidate OTP record, and return JWT pair.
        ``users_collection`` is the role-specific Mongo collection (customers/drivers/admins).
        """
        otp_doc = await self._load_valid_record(
            role=role,
            mobile_number=mobile_number,
            otp=otp,
            purpose=purpose,
        )
        user_id = self._user_id_for_lookup(otp_doc["user_id"])

        user_doc = await users_collection.find_one({"_id": user_id})
        if not user_doc:
            raise HTTPException(status_code=404, detail="User not found")

        await users_collection.update_one(
            {"_id": user_id},
            {"$set": {"otp_verified": True, "updated_at": datetime.utcnow()}},
        )
        await self.mark_verified(otp_doc["_id"])

        is_super_admin = bool(user_doc.get("is_super_admin", False)) if role == "admin" else False
        subject = str(user_id)
        return TokenResponse(
            access_token=create_access_token(
                subject=subject,
                role=role,
                is_super_admin=is_super_admin,
            ),
            refresh_token=create_refresh_token(
                subject=subject,
                role=role,
                is_super_admin=is_super_admin,
            ),
        )


otp_service = OtpService()
