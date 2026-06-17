"""Scheduled (cron-like) Celery tasks."""
import structlog

from app.celery_app import celery_app

logger = structlog.get_logger(__name__)


@celery_app.task(name="app.tasks.scheduled.daily_cleanup")
def daily_cleanup():
    logger.info("daily_cleanup_placeholder")
    return {"status": "ok", "task": "daily_cleanup"}
