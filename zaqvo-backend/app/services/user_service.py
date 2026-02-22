"""User service: create, get by email, etc. (placeholder)."""
from app.models.user import UserCreate, UserInDB
from app.db.mongodb import get_db


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
    from datetime import datetime
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
