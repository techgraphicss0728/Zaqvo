"""Deprecated import path — tasks live in ``app.workers``."""
from app.workers.scheduled import daily_cleanup  # noqa: F401
