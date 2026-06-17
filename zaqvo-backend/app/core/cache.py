"""Redis cache helpers (async). Degrades gracefully if Redis is down."""
from __future__ import annotations

import json
from typing import Any

import redis.asyncio as aioredis

from app.core.config import settings

_redis: aioredis.Redis | None = None


async def connect_redis() -> None:
    global _redis
    if not settings.CACHE_ENABLED:
        return
    try:
        _redis = aioredis.from_url(settings.REDIS_URL, decode_responses=True)
        await _redis.ping()
    except Exception:
        _redis = None


async def close_redis() -> None:
    global _redis
    if _redis is not None:
        await _redis.close()
        _redis = None


def redis_available() -> bool:
    return _redis is not None


async def bump_catalog_epoch() -> None:
    if _redis is None:
        return
    try:
        await _redis.incr(settings.CATALOG_CACHE_EPOCH_KEY)
    except Exception:
        pass


async def get_catalog_epoch() -> str:
    if _redis is None:
        return "0"
    try:
        v = await _redis.get(settings.CATALOG_CACHE_EPOCH_KEY)
        return str(v) if v is not None else "0"
    except Exception:
        return "0"


async def cache_get_json(key: str) -> Any | None:
    if _redis is None:
        return None
    try:
        raw = await _redis.get(key)
        if raw is None:
            return None
        return json.loads(raw)
    except Exception:
        return None


async def cache_set_json(key: str, value: Any, ttl_seconds: int) -> None:
    if _redis is None:
        return
    try:
        await _redis.setex(key, ttl_seconds, json.dumps(value, default=str))
    except Exception:
        pass


async def cache_acquire_idempotency(key: str, ttl_seconds: int) -> bool:
    """Return True if lock acquired (first request), False if duplicate key."""
    if _redis is None:
        return True
    try:
        full = f"{settings.IDEMPOTENCY_KEY_PREFIX}:{key}"
        ok = await _redis.set(full, "1", nx=True, ex=ttl_seconds)
        return bool(ok)
    except Exception:
        return True
