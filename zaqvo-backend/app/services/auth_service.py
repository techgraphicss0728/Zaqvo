from datetime import datetime, timedelta
import random
from typing import Literal

from bson import ObjectId
from fastapi import HTTPException
from motor.motor_asyncio import AsyncIOMotorDatabase

from app.core.security import create_access_token, create_refresh_token
from app.db.mongodb import get_db
from app.schemas.auth import (
    RoleLiteral,
    TokenResponse,
    CustomerSignupRequest,
    DriverSignupRequest,
    AdminSignupRequest,
    OTPVerifyRequest,
    LoginOTPRequest,
)
from app.services.sms_service import send_otp_sms


def _get_db_or_fail() -> AsyncIOMotorDatabase:
    db = get_db()
    if db is None:
        raise HTTPException(status_code=500, detail="Database not initialized")
    return db


def _get_collections(db: AsyncIOMotorDatabase, role: RoleLiteral):
    if role == "customer":
        return db["customers"]
    if role == "driver":
        return db["drivers"]
    if role == "admin":
        return db["admins"]
    raise ValueError("Invalid role")


def _get_otp_collection(db: AsyncIOMotorDatabase):
    return db["otps"]


def _generate_otp() -> str:
    return f"{random.randint(0, 999999):06d}"


async def _create_or_get_user_for_signup(
    db: AsyncIOMotorDatabase,
    role: RoleLiteral,
    mobile_number: str,
    payload: CustomerSignupRequest | DriverSignupRequest | AdminSignupRequest,
) -> ObjectId:
    users_col = _get_collections(db, role)
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
        body: CustomerSignupRequest = payload  # type: ignore[assignment]
        base_doc.update(
            {
                "name": body.name,
                "photo": body.photo,
                "is_active": True,
                "password_hash": None,
                "address_id": None,
            }
        )
    elif role == "driver":
        body = payload  # type: ignore[assignment]
        base_doc.update(
            {
                "name": body.name,
                "photo": body.photo,
                "license_number": body.license_number,
                "vehicle_type": body.vehicle_type,
                "vehicle_number": body.vehicle_number,
                "status": "offline",
                "is_verified": False,
                "is_active": True,
                "rating": 0.0,
                "total_deliveries": 0,
                "last_online": None,
            }
        )
    else:  # admin
        body = payload  # type: ignore[assignment]
        base_doc.update(
            {
                "name": body.name,
                "last_login": None,
            }
        )

    if existing:
        await users_col.update_one(
            {"_id": existing["_id"]},
            {"$set": base_doc},
        )
        return existing["_id"]

    result = await users_col.insert_one(base_doc)
    return result.inserted_id


async def _create_or_update_otp(
    db: AsyncIOMotorDatabase,
    user_id: ObjectId,
    role: RoleLiteral,
    mobile_number: str,
    *,
    purpose: Literal["signup", "login"],
) -> str:
    otps = _get_otp_collection(db)
    code = _generate_otp()
    expires_at = datetime.utcnow() + timedelta(minutes=5)
    await otps.update_one(
        {"user_id": user_id, "role": role, "mobile_number": mobile_number, "purpose": purpose},
        {
            "$set": {
                "code": code,
                "expires_at": expires_at,
                "verified": False,
                "updated_at": datetime.utcnow(),
            },
            "$setOnInsert": {
                "created_at": datetime.utcnow(),
                "purpose": purpose,
            },
        },
        upsert=True,
    )
    return code


async def _verify_otp_and_issue_tokens(
    db: AsyncIOMotorDatabase,
    role: RoleLiteral,
    mobile_number: str,
    otp: str,
    *,
    purpose: Literal["signup", "login"],
) -> TokenResponse:
    otps = _get_otp_collection(db)
    otp_doc = await otps.find_one(
        {
            "mobile_number": mobile_number,
            "role": role,
            "purpose": purpose,
        }
    )
    if not otp_doc or otp_doc.get("code") != otp:
        raise HTTPException(status_code=400, detail="Invalid OTP")

    if otp_doc.get("expires_at") and otp_doc["expires_at"] < datetime.utcnow():
        raise HTTPException(status_code=400, detail="OTP expired")

    user_id = otp_doc.get("user_id")
    if not user_id:
        raise HTTPException(status_code=400, detail="OTP not linked to user")

    users_col = _get_collections(db, role)
    user_doc = await users_col.find_one({"_id": user_id})
    if not user_doc:
        raise HTTPException(status_code=404, detail="User not found")

    await users_col.update_one(
        {"_id": user_id},
        {"$set": {"otp_verified": True, "updated_at": datetime.utcnow()}},
    )
    await otps.update_one(
        {"_id": otp_doc["_id"]},
        {"$set": {"verified": True, "verified_at": datetime.utcnow()}},
    )

    access = create_access_token(subject=str(user_id), role=role)
    refresh = create_refresh_token(subject=str(user_id), role=role)
    return TokenResponse(access_token=access, refresh_token=refresh)


async def customer_signup_send_otp(body: CustomerSignupRequest) -> dict:
    db = _get_db_or_fail()
    user_id = await _create_or_get_user_for_signup(
        db,
        role="customer",
        mobile_number=body.mobile_number,
        payload=body,
    )
    code = await _create_or_update_otp(
        db,
        user_id=user_id,
        role="customer",
        mobile_number=body.mobile_number,
        purpose="signup",
    )
    sms_response = await send_otp_sms(body.mobile_number, code)
    if not sms_response.get("success"):
        raise HTTPException(
            status_code=500,
            detail=f"SMS sending failed: {sms_response.get('message')}",
        )
    return {"message": "OTP sent to mobile number"}


async def customer_signup_verify_otp(body: OTPVerifyRequest) -> TokenResponse:
    db = _get_db_or_fail()
    return await _verify_otp_and_issue_tokens(
        db,
        role="customer",
        mobile_number=body.mobile_number,
        otp=body.otp,
        purpose="signup",
    )


async def driver_signup_send_otp(body: DriverSignupRequest) -> dict:
    db = _get_db_or_fail()
    user_id = await _create_or_get_user_for_signup(
        db,
        role="driver",
        mobile_number=body.mobile_number,
        payload=body,
    )
    code = await _create_or_update_otp(
        db,
        user_id=user_id,
        role="driver",
        mobile_number=body.mobile_number,
        purpose="signup",
    )
    sms_response = await send_otp_sms(body.mobile_number, code)
    if not sms_response.get("success"):
        raise HTTPException(
            status_code=500,
            detail=f"SMS sending failed: {sms_response.get('message')}",
        )
    return {"message": "OTP sent to mobile number"}


async def driver_signup_verify_otp(body: OTPVerifyRequest) -> TokenResponse:
    db = _get_db_or_fail()
    return await _verify_otp_and_issue_tokens(
        db,
        role="driver",
        mobile_number=body.mobile_number,
        otp=body.otp,
        purpose="signup",
    )


async def admin_signup_send_otp(body: AdminSignupRequest) -> dict:
    db = _get_db_or_fail()
    user_id = await _create_or_get_user_for_signup(
        db,
        role="admin",
        mobile_number=body.mobile_number,
        payload=body,
    )
    code = await _create_or_update_otp(
        db,
        user_id=user_id,
        role="admin",
        mobile_number=body.mobile_number,
        purpose="signup",
    )
    sms_response = await send_otp_sms(body.mobile_number, code)
    if not sms_response.get("success"):
        raise HTTPException(
            status_code=500,
            detail=f"SMS sending failed: {sms_response.get('message')}",
        )
    return {"message": "OTP sent to mobile number"}


async def admin_signup_verify_otp(body: OTPVerifyRequest) -> TokenResponse:
    db = _get_db_or_fail()
    return await _verify_otp_and_issue_tokens(
        db,
        role="admin",
        mobile_number=body.mobile_number,
        otp=body.otp,
        purpose="signup",
    )


async def customer_login_send_otp(body: LoginOTPRequest) -> dict:
    db = _get_db_or_fail()
    users_col = _get_collections(db, "customer")
    user = await users_col.find_one({"mobile_number": body.mobile_number, "otp_verified": True})
    if not user:
        raise HTTPException(status_code=404, detail="Customer not found or not verified")
    code = await _create_or_update_otp(
        db,
        user_id=user["_id"],
        role="customer",
        mobile_number=body.mobile_number,
        purpose="login",
    )
    sms_response = await send_otp_sms(body.mobile_number, code)
    if not sms_response.get("success"):
        raise HTTPException(
            status_code=500,
            detail=f"SMS sending failed: {sms_response.get('message')}",
        )
    return {"message": "OTP sent to mobile number"}


async def customer_login_verify_otp(body: OTPVerifyRequest) -> TokenResponse:
    db = _get_db_or_fail()
    return await _verify_otp_and_issue_tokens(
        db,
        role="customer",
        mobile_number=body.mobile_number,
        otp=body.otp,
        purpose="login",
    )


async def driver_login_send_otp(body: LoginOTPRequest) -> dict:
    db = _get_db_or_fail()
    users_col = _get_collections(db, "driver")
    user = await users_col.find_one(
        {
            "mobile_number": body.mobile_number,
            "otp_verified": True,
            "is_active": True,
        }
    )
    if not user:
        raise HTTPException(status_code=404, detail="Driver not found or not active/verified")
    code = await _create_or_update_otp(
        db,
        user_id=user["_id"],
        role="driver",
        mobile_number=body.mobile_number,
        purpose="login",
    )
    sms_response = await send_otp_sms(body.mobile_number, code)
    if not sms_response.get("success"):
        raise HTTPException(
            status_code=500,
            detail=f"SMS sending failed: {sms_response.get('message')}",
        )
    return {"message": "OTP sent to mobile number"}


async def driver_login_verify_otp(body: OTPVerifyRequest) -> TokenResponse:
    db = _get_db_or_fail()
    return await _verify_otp_and_issue_tokens(
        db,
        role="driver",
        mobile_number=body.mobile_number,
        otp=body.otp,
        purpose="login",
    )


async def admin_login_send_otp(body: LoginOTPRequest) -> dict:
    db = _get_db_or_fail()
    users_col = _get_collections(db, "admin")
    user = await users_col.find_one({"mobile_number": body.mobile_number, "otp_verified": True})
    if not user:
        raise HTTPException(status_code=404, detail="Admin not found or not verified")
    code = await _create_or_update_otp(
        db,
        user_id=user["_id"],
        role="admin",
        mobile_number=body.mobile_number,
        purpose="login",
    )
    sms_response = await send_otp_sms(body.mobile_number, code)
    if not sms_response.get("success"):
        raise HTTPException(
            status_code=500,
            detail=f"SMS sending failed: {sms_response.get('message')}",
        )
    return {"message": "OTP sent to mobile number"}


async def admin_login_verify_otp(body: OTPVerifyRequest) -> TokenResponse:
    db = _get_db_or_fail()
    return await _verify_otp_and_issue_tokens(
        db,
        role="admin",
        mobile_number=body.mobile_number,
        otp=body.otp,
        purpose="login",
    )

