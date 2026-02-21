"""Scheduled (cron-like) Celery tasks."""
from app.celery_app import celery_app


@celery_app.task(name="app.tasks.scheduled.daily_cleanup")
def daily_cleanup():
    # Placeholder: e.g. expire old sessions, cleanup temp data
    return {"status": "ok", "task": "daily_cleanup"}
