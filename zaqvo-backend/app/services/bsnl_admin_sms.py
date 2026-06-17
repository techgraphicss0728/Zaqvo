"""
BSNL bulk SMS — admin dashboard login OTP channel.

Uses a dedicated DLT template (``BSNL_ADMIN_LOGIN_TEMPLATE_ID``) and header
(``BSNL_ADMIN_SMS_HEADER``). Add new SMS channels as sibling modules under
``app/services/sms/`` when needed.
"""
from __future__ import annotations

from typing import Any

import httpx
import structlog

from app.core.config import settings

logger = structlog.get_logger(__name__)

# Shared result shape for all send helpers in this module.
SmsResult = dict[str, Any]


def _resolve_template_id(tpid: str | None) -> str | None:
    resolved = (tpid or settings.BSNL_ADMIN_LOGIN_TEMPLATE_ID or "").strip()
    return resolved or None


def _build_admin_login_payload(mobile_number: str, otp: str, template_id: str) -> dict[str, Any]:
    return {
        "Header": settings.BSNL_ADMIN_SMS_HEADER,
        "Target": mobile_number,
        "Is_Unicode": "0",
        "Is_Flash": "0",
        "Message_Type": "SI",
        "Entity_Id": settings.BSNL_ENTITY_ID,
        "Content_Template_Id": template_id,
        "Consent_Template_Id": None,
        "Template_Keys_and_Values": [
            {"Key": "mobile", "Value": mobile_number},
            {"Key": "otp", "Value": otp},
        ],
    }


def _build_headers() -> dict[str, str]:
    return {
        "Authorization": f"Bearer {settings.BSNL_AUTH_TOKEN}",
        "Content-Type": "application/json; charset=utf-8",
    }


def _parse_bsnl_response(response: httpx.Response) -> SmsResult:
    if response.status_code != 200:
        return {
            "success": False,
            "message": "Non-200 HTTP response",
            "status_code": response.status_code,
            "error": response.text,
        }

    response_data = response.json()
    if response_data.get("Error") is None:
        return {
            "success": True,
            "message": "OTP sent successfully",
            "message_id": response_data.get("Message_Id"),
        }

    return {
        "success": False,
        "message": "BSNL returned error",
        "error": response_data.get("Error"),
    }


def _dev_log_otp_instead_of_sms(mobile_number: str, otp: str) -> SmsResult:
    """Local dev: skip BSNL when token is not set — OTP is printed in the API terminal."""
    suffix = mobile_number[-4:] if len(mobile_number) >= 4 else mobile_number
    logger.warning(
        "admin_login_otp_dev_mode",
        mobile_suffix=suffix,
        otp=otp,
        hint="Set BSNL_AUTH_TOKEN in .env to send real SMS",
    )
    return {
        "success": True,
        "message": "OTP logged in server console (development mode)",
        "dev_mode": True,
    }


def _should_use_dev_otp_fallback() -> bool:
    return settings.APP_ENV == "development" and not settings.BSNL_AUTH_TOKEN.strip()


def _validate_config() -> SmsResult | None:
    """Return an error result when SMS cannot be sent due to missing config."""
    if _should_use_dev_otp_fallback():
        return None
    if not _resolve_template_id(None):
        return {"success": False, "message": "Admin login SMS template is not configured"}
    if not settings.BSNL_AUTH_TOKEN:
        return {"success": False, "message": "BSNL auth token is not configured"}
    return None


def send_admin_login_otp_sms_sync(mobile_number: str, otp: str, tpid: str | None = None) -> SmsResult:
    """Blocking send — suitable for Celery workers or scripts."""
    if _should_use_dev_otp_fallback():
        return _dev_log_otp_instead_of_sms(mobile_number, otp)

    config_error = _validate_config()
    if config_error:
        return config_error

    template_id = _resolve_template_id(tpid)
    assert template_id  # guarded by _validate_config

    try:
        with httpx.Client(timeout=15) as client:
            response = client.post(
                settings.BSNL_SMS_API_URL,
                json=_build_admin_login_payload(mobile_number, otp, template_id),
                headers=_build_headers(),
            )
        return _parse_bsnl_response(response)
    except Exception as exc:  # pragma: no cover - network errors
        return {"success": False, "message": "Exception while sending SMS", "error": str(exc)}


async def send_admin_login_otp_sms(mobile_number: str, otp: str, tpid: str | None = None) -> SmsResult:
    """Async send — used by admin login flow in the API process."""
    if _should_use_dev_otp_fallback():
        return _dev_log_otp_instead_of_sms(mobile_number, otp)

    config_error = _validate_config()
    if config_error:
        return config_error

    template_id = _resolve_template_id(tpid)
    assert template_id

    try:
        async with httpx.AsyncClient(timeout=15) as client:
            response = await client.post(
                settings.BSNL_SMS_API_URL,
                json=_build_admin_login_payload(mobile_number, otp, template_id),
                headers=_build_headers(),
            )
        return _parse_bsnl_response(response)
    except Exception as exc:  # pragma: no cover - network errors
        return {"success": False, "message": "Exception while sending SMS", "error": str(exc)}
