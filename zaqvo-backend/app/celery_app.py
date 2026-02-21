"""
Celery app for background and scheduled tasks.
Broker: Redis. Run worker and beat separately for scaling.
"""
from celery import Celery
from app.core.config import settings

celery_app = Celery(
    "zaqvo",
    broker=settings.CELERY_BROKER_URL,
    backend=settings.REDIS_URL,
    include=["app.tasks"],
)

celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
    task_track_started=True,
    task_time_limit=300,
    worker_prefetch_multiplier=1,
)

# Celery Beat schedule (cron-like)
celery_app.conf.beat_schedule = {
    "daily-cleanup": {
        "task": "app.tasks.scheduled.daily_cleanup",
        "schedule": 60.0 * 60 * 24,  # every 24 hours
    },
}
