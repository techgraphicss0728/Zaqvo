from typing import Any

import httpx

from app.core.config import settings


def send_otp_sms_sync(mobile_number: str, otp: str, tpid: str | None = None) -> dict[str, Any]:
    """Blocking SMS send for Celery workers (sync HTTP client)."""
    api_url = settings.BSNL_SMS_API_URL
    payload = {
        "Header": settings.BSNL_SMS_HEADER,
        "Target": mobile_number,
        "Is_Unicode": "0",
        "Is_Flash": "0",
        "Message_Type": "SI",
        "Entity_Id": settings.BSNL_ENTITY_ID,
        "Content_Template_Id": tpid or settings.BSNL_TEMPLATE_ID,
        "Consent_Template_Id": None,
        "Template_Keys_and_Values": [
            {"Key": "pin", "Value": otp},
            {"Key": "min", "Value": "5"},
            {"Key": "name", "Value": settings.SMS_SENDER_NAME},
        ],
    }
    headers = {
        "Authorization": f"Bearer {settings.BSNL_AUTH_TOKEN}",
        "Content-Type": "application/json; charset=utf-8",
    }
    try:
        with httpx.Client(timeout=15) as client:
            response = client.post(api_url, json=payload, headers=headers)
        if response.status_code != 200:
            return {
                "success": False,
                "message": "Non-200 response from SMS API",
                "error": response.text,
            }
        response_data = response.json()
        if response_data.get("Error") is None and response_data.get("Message_Id"):
            return {
                "success": True,
                "message": "OTP sent successfully",
                "message_id": response_data.get("Message_Id"),
            }
        return {
            "success": False,
            "message": "Failed to send OTP",
            "error": response_data,
        }
    except Exception as e:  # pragma: no cover - network errors
        return {
            "success": False,
            "message": "Exception occurred",
            "error": str(e),
        }


async def send_otp_sms(mobile_number: str, otp: str, tpid: str | None = None) -> dict[str, Any]:
    """Async SMS (tests / optional inline use); production OTP uses Celery + ``send_otp_sms_sync``."""
    api_url = settings.BSNL_SMS_API_URL

    payload = {
        "Header": settings.BSNL_SMS_HEADER,
        "Target": mobile_number,
        "Is_Unicode": "0",
        "Is_Flash": "0",
        "Message_Type": "SI",
        "Entity_Id": settings.BSNL_ENTITY_ID,
        "Content_Template_Id": tpid or settings.BSNL_TEMPLATE_ID,
        "Consent_Template_Id": None,
        "Template_Keys_and_Values": [
            {"Key": "pin", "Value": otp},
            {"Key": "min", "Value": "5"},
            {"Key": "name", "Value": settings.SMS_SENDER_NAME},
        ],
    }

    headers = {
        "Authorization": f"Bearer {settings.BSNL_AUTH_TOKEN}",
        "Content-Type": "application/json; charset=utf-8",
    }

    try:
        async with httpx.AsyncClient(timeout=10) as client:
            response = await client.post(api_url, json=payload, headers=headers)

        if response.status_code != 200:
            return {
                "success": False,
                "message": "Non-200 response from SMS API",
                "error": response.text,
            }

        response_data = response.json()

        if response_data.get("Error") is None and response_data.get("Message_Id"):
            return {
                "success": True,
                "message": "OTP sent successfully",
                "message_id": response_data.get("Message_Id"),
            }

        return {
            "success": False,
            "message": "Failed to send OTP",
            "error": response_data,
        }

    except Exception as e:  # pragma: no cover - network errors
        return {
            "success": False,
            "message": "Exception occurred",
            "error": str(e),
        }

