"""User profile and legacy user helpers."""
from datetime import datetime

from bson import ObjectId
from bson.errors import InvalidId
from fastapi import HTTPException

from app.db.mongodb import get_db
from app.models.user import UserCreate, UserInDB
from app.schemas.profile import ProfileMeResponse
from app.services.permission_service import permission_service


def _collection_for_role(role: str) -> str:
    if role == "customer":
        return "customers"
    if role == "driver":
        return "drivers"
    if role == "admin":
        return "admins"
    raise HTTPException(status_code=400, detail="Invalid role")


class UserService:
    async def get_profile_me(self, role: str, sub: str | None) -> ProfileMeResponse:
        if not sub:
            raise HTTPException(status_code=401, detail="Not authenticated")
        try:
            oid = ObjectId(sub)
        except InvalidId as e:
            raise HTTPException(status_code=400, detail="Invalid user id") from e

        db = get_db()
        if db is None:
            raise HTTPException(status_code=500, detail="Database not initialized")

        doc = await db[_collection_for_role(role)].find_one({"_id": oid})
        if not doc:
            raise HTTPException(status_code=404, detail="User not found")

        return ProfileMeResponse(
            id=str(doc["_id"]),
            role=role,
            name=doc.get("name"),
            mobile_number=doc.get("mobile_number"),
            is_super_admin=bool(doc.get("is_super_admin", False)),
            role_id=doc.get("role_id"),
            role_slug=doc.get("role_slug"),
            role_name=doc.get("role_name"),
            permissions=(
                await permission_service.resolve_for_admin(doc) if role == "admin" else {}
            ),
        )


user_service = UserService()


async def get_user_by_email(email: str) -> UserInDB | None:
    db = get_db()
    if not db:
        return None
    doc = await db.users.find_one({"email": email})
    if not doc:
        return None
    doc["id"] = str(doc["_id"])
    return UserInDB(**doc)


async def create_user(data: UserCreate, hashed_password: str) -> UserInDB:
    db = get_db()
    now = datetime.utcnow()
    doc = {
        "email": data.email,
        "full_name": data.full_name,
        "role": data.role,
        "hashed_password": hashed_password,
        "created_at": now,
        "updated_at": now,
    }
    r = await db.users.insert_one(doc)
    doc["id"] = str(r.inserted_id)
    doc["created_at"] = now
    doc["updated_at"] = now
    return UserInDB(**doc)
