"""Auth: mobile + OTP login/signup for customer, driver, and admin."""
from fastapi import APIRouter, Request

from app.core.limiter import limiter
from app.schemas.auth import (
    TokenResponse,
    CustomerSignupRequest,
    DriverSignupRequest,
    AdminSignupRequest,
    OTPVerifyRequest,
    LoginOTPRequest,
)
from app.services import auth_service

router = APIRouter()


@router.post("/customer/signup/send-otp")
@limiter.limit("5/minute")
async def customer_signup_send_otp(request: Request, body: CustomerSignupRequest):
    return await auth_service.customer_signup_send_otp(body)


@router.post("/customer/signup/verify-otp", response_model=TokenResponse)
@limiter.limit("10/minute")
async def customer_signup_verify_otp(request: Request, body: OTPVerifyRequest):
    return await auth_service.customer_signup_verify_otp(body)


@router.post("/driver/signup/send-otp")
@limiter.limit("5/minute")
async def driver_signup_send_otp(request: Request, body: DriverSignupRequest):
    return await auth_service.driver_signup_send_otp(body)


@router.post("/driver/signup/verify-otp", response_model=TokenResponse)
@limiter.limit("10/minute")
async def driver_signup_verify_otp(request: Request, body: OTPVerifyRequest):
    return await auth_service.driver_signup_verify_otp(body)


@router.post("/admin/signup/send-otp")
@limiter.limit("5/minute")
async def admin_signup_send_otp(request: Request, body: AdminSignupRequest):
    return await auth_service.admin_signup_send_otp(body)


@router.post("/admin/signup/verify-otp", response_model=TokenResponse)
@limiter.limit("10/minute")
async def admin_signup_verify_otp(request: Request, body: OTPVerifyRequest):
    return await auth_service.admin_signup_verify_otp(body)


@router.post("/customer/login/send-otp")
@limiter.limit("10/minute")
async def customer_login_send_otp(request: Request, body: LoginOTPRequest):
    return await auth_service.customer_login_send_otp(body)


@router.post("/customer/login/verify-otp", response_model=TokenResponse)
@limiter.limit("20/minute")
async def customer_login_verify_otp(request: Request, body: OTPVerifyRequest):
    return await auth_service.customer_login_verify_otp(body)


@router.post("/driver/login/send-otp")
@limiter.limit("10/minute")
async def driver_login_send_otp(request: Request, body: LoginOTPRequest):
    return await auth_service.driver_login_send_otp(body)


@router.post("/driver/login/verify-otp", response_model=TokenResponse)
@limiter.limit("20/minute")
async def driver_login_verify_otp(request: Request, body: OTPVerifyRequest):
    return await auth_service.driver_login_verify_otp(body)


@router.post("/admin/login/send-otp")
@limiter.limit("10/minute")
async def admin_login_send_otp(request: Request, body: LoginOTPRequest):
    return await auth_service.admin_login_send_otp(body)


@router.post("/admin/login/verify-otp", response_model=TokenResponse)
@limiter.limit("20/minute")
async def admin_login_verify_otp(request: Request, body: OTPVerifyRequest):
    return await auth_service.admin_login_verify_otp(body)
