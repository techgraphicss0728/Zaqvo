"""Async SMS / notification delivery via Celery."""
import structlog

from app.celery_app import celery_app
from app.services.sms_service import send_otp_sms_sync

logger = structlog.get_logger(__name__)


@celery_app.task(
    bind=True,
    name="app.workers.notifications.send_otp_sms",
    autoretry_for=(Exception,),
    retry_kwargs={"max_retries": 4, "countdown": 5},
)
def send_otp_sms_task(self, mobile_number: str, otp: str, tpid: str | None = None):
    result = send_otp_sms_sync(mobile_number, otp, tpid)
    if not result.get("success"):
        logger.warning(
            "sms_send_failed",
            mobile_suffix=mobile_number[-4:] if len(mobile_number) >= 4 else "",
            detail=result.get("message"),
        )
        raise RuntimeError(result.get("message", "SMS failed"))
    return result


@celery_app.task(
    bind=True,
    name="app.workers.notifications.send_email",
    autoretry_for=(Exception,),
    retry_kwargs={"max_retries": 3, "countdown": 10},
)
def send_email_task(self, *, subject: str, body: str, to_address: str):
    logger.info("email_placeholder", subject=subject, to=to_address)
    return {"ok": True, "queued": "placeholder"}
