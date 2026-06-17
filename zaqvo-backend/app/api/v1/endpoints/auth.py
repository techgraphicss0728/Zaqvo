"""Auth: OTP login/signup for mobile apps; OTP-only login for admin dashboard."""
from fastapi import APIRouter, Request, Response

from app.api.helpers.auth_cookies import clear_auth_cookies, set_auth_cookies
from app.core.config import settings
from app.core.limiter import limiter
from app.schemas.auth import (
    AdminAuthResponse,
    AdminSignupRequest,
    CustomerSignupRequest,
    DriverSignupRequest,
    LoginOTPRequest,
    OTPVerifyRequest,
    OtpMessageResponse,
    RefreshTokenRequest,
    TokenResponse,
)
from app.services.admin_auth_service import admin_auth_service
from app.services.auth_service import auth_service

router = APIRouter()


@router.post("/refresh", response_model=TokenResponse)
@limiter.limit("30/minute")
async def refresh_tokens(request: Request, response: Response, body: RefreshTokenRequest):
    if not body.refresh_token:
        body.refresh_token = request.cookies.get(settings.AUTH_REFRESH_COOKIE_NAME)
    token_response = await auth_service.refresh_tokens(body)
    set_auth_cookies(
        response,
        access_token=token_response.access_token,
        refresh_token=token_response.refresh_token,
    )
    return token_response


@router.post("/admin/login/send-otp", response_model=OtpMessageResponse)
@limiter.limit("10/minute")
async def admin_login_send_otp(request: Request, body: LoginOTPRequest):
    return await admin_auth_service.login_send_otp(body)


@router.post("/admin/login/verify-otp", response_model=AdminAuthResponse)
@limiter.limit("20/minute")
async def admin_login_verify_otp(request: Request, response: Response, body: OTPVerifyRequest):
    auth_response = await admin_auth_service.login_verify_otp(body)
    set_auth_cookies(
        response,
        access_token=auth_response.access_token,
        refresh_token=auth_response.refresh_token,
    )
    return auth_response


@router.post("/logout")
@limiter.limit("30/minute")
async def admin_logout(request: Request, response: Response):
    clear_auth_cookies(response)
    return {"ok": True}


@router.post("/customer/signup/send-otp", response_model=OtpMessageResponse)
@limiter.limit("5/minute")
async def customer_signup_send_otp(request: Request, body: CustomerSignupRequest):
    return await auth_service.customer_signup_send_otp(body)


@router.post("/customer/signup/verify-otp", response_model=TokenResponse)
@limiter.limit("10/minute")
async def customer_signup_verify_otp(request: Request, body: OTPVerifyRequest):
    return await auth_service.customer_signup_verify_otp(body)


@router.post("/driver/signup/send-otp", response_model=OtpMessageResponse)
@limiter.limit("5/minute")
async def driver_signup_send_otp(request: Request, body: DriverSignupRequest):
    return await auth_service.driver_signup_send_otp(body)


@router.post("/driver/signup/verify-otp", response_model=TokenResponse)
@limiter.limit("10/minute")
async def driver_signup_verify_otp(request: Request, body: OTPVerifyRequest):
    return await auth_service.driver_signup_verify_otp(body)


@router.post("/admin/signup/send-otp", response_model=OtpMessageResponse)
@limiter.limit("5/minute")
async def admin_signup_send_otp(request: Request, body: AdminSignupRequest):
    return await auth_service.admin_signup_send_otp(body)


@router.post("/admin/signup/verify-otp", response_model=TokenResponse)
@limiter.limit("10/minute")
async def admin_signup_verify_otp(request: Request, body: OTPVerifyRequest):
    return await auth_service.admin_signup_verify_otp(body)


@router.post("/customer/login/send-otp", response_model=OtpMessageResponse)
@limiter.limit("10/minute")
async def customer_login_send_otp(request: Request, body: LoginOTPRequest):
    return await auth_service.customer_login_send_otp(body)


@router.post("/customer/login/verify-otp", response_model=TokenResponse)
@limiter.limit("20/minute")
async def customer_login_verify_otp(request: Request, body: OTPVerifyRequest):
    return await auth_service.customer_login_verify_otp(body)


@router.post("/driver/login/send-otp", response_model=OtpMessageResponse)
@limiter.limit("10/minute")
async def driver_login_send_otp(request: Request, body: LoginOTPRequest):
    return await auth_service.driver_login_send_otp(body)


@router.post("/driver/login/verify-otp", response_model=TokenResponse)
@limiter.limit("20/minute")
async def driver_login_verify_otp(request: Request, body: OTPVerifyRequest):
    return await auth_service.driver_login_verify_otp(body)
