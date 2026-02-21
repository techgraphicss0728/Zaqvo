"""MongoDB connection and lifecycle. Uses motor for async."""
from motor.motor_asyncio import AsyncIOMotorClient
from pymongo.errors import ServerSelectionTimeoutError

from app.core.config import settings

_client: AsyncIOMotorClient | None = None
_db = None


async def connect_mongo() -> None:
    global _client, _db
    _client = AsyncIOMotorClient(
        settings.MONGODB_URI,
        maxPoolSize=50,
        minPoolSize=10,
        serverSelectionTimeoutMS=5000,
    )
    _db = _client[settings.MONGODB_DB_NAME]


async def close_mongo() -> None:
    global _client
    if _client:
        _client.close()
        _client = None


def get_db():
    return _db


async def is_ready() -> bool:
    try:
        if _client:
            await _client.admin.command("ping")
            return True
    except ServerSelectionTimeoutError:
        pass
    return False
