"""Super-admin endpoints for dashboard user management."""
from fastapi import APIRouter, Query, Request

from app.api.deps import ensure_super_admin, get_request_user
from app.core.limiter import limiter
from app.schemas.admin_users import (
    AdminUserCreateSendOtpRequest,
    AdminUserCreateVerifyOtpRequest,
    AdminUserListResponse,
    AdminUserStatusRequest,
    AdminUserSummaryResponse,
    AdminUserUpdateRequest,
)
from app.schemas.auth import OtpMessageResponse
from app.services.admin_user_service import admin_user_service

router = APIRouter()


@router.get("/users", response_model=AdminUserListResponse)
@limiter.limit("60/minute")
async def list_admin_users(
    request: Request,
    page: int = Query(1, ge=1),
    limit: int = Query(10, ge=1, le=100),
):
    user = get_request_user(request)
    ensure_super_admin(user)
    return await admin_user_service.list_users(page=page, limit=limit)


@router.post("/users/send-otp", response_model=OtpMessageResponse)
@limiter.limit("10/minute")
async def create_admin_user_send_otp(request: Request, body: AdminUserCreateSendOtpRequest):
    user = get_request_user(request)
    ensure_super_admin(user)
    result = await admin_user_service.create_send_otp(
        body,
        created_by_admin_id=str(user.get("sub")),
    )
    return OtpMessageResponse(message=result["message"])


@router.post("/users/verify-otp", response_model=AdminUserSummaryResponse)
@limiter.limit("20/minute")
async def create_admin_user_verify_otp(request: Request, body: AdminUserCreateVerifyOtpRequest):
    user = get_request_user(request)
    ensure_super_admin(user)
    return await admin_user_service.create_verify_otp(body)


@router.patch("/users/{user_id}", response_model=AdminUserSummaryResponse)
@limiter.limit("30/minute")
async def update_admin_user(request: Request, user_id: str, body: AdminUserUpdateRequest):
    user = get_request_user(request)
    ensure_super_admin(user)
    return await admin_user_service.update_user(user_id, body)


@router.patch("/users/{user_id}/status", response_model=AdminUserSummaryResponse)
@limiter.limit("30/minute")
async def set_admin_user_status(request: Request, user_id: str, body: AdminUserStatusRequest):
    user = get_request_user(request)
    ensure_super_admin(user)
    return await admin_user_service.set_user_status(user_id, body)
