"""Payment helpers — idempotency guard for future payment endpoints."""

from app.core import cache


async def try_acquire_idempotency_key(
    key: str | None,
    *,
    ttl_seconds: int = 86400,
) -> tuple[bool, str | None]:
    """
    Returns (should_proceed, conflict_detail).

    When ``key`` is None, always proceeds (no deduplication).
    When Redis is unavailable, proceeds (fail-open).
    """
    if not key or not key.strip():
        return True, None
    acquired = await cache.cache_acquire_idempotency(key.strip(), ttl_seconds)
    if acquired:
        return True, None
    return False, "Duplicate idempotency key"
