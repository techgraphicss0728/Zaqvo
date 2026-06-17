"""Rate limiting for API (handles high request volume)."""
from slowapi import Limiter
from slowapi.util import get_remote_address

from app.core.config import settings

_storage_uri = settings.REDIS_URL if settings.USE_REDIS_RATE_LIMIT else None

limiter = Limiter(
    key_func=get_remote_address,
    default_limits=[f"{settings.RATE_LIMIT_PER_MINUTE}/minute"],
    storage_uri=_storage_uri,
)
