"""Users profile (JWT validated in AuthMiddleware)."""
from fastapi import APIRouter, Request

from app.api.deps import get_request_user
from app.core.limiter import limiter
from app.schemas.profile import FcmTokenRequest, ProfileMeResponse
from app.services.user_service import user_service

router = APIRouter()


@router.get("/me", response_model=ProfileMeResponse)
@limiter.limit("60/minute")
async def me(request: Request):
    user = get_request_user(request)
    return await user_service.get_profile_me(user["role"], user.get("sub"))


@router.post("/me/fcm-token")
@limiter.limit("30/minute")
async def update_fcm_token(request: Request, body: FcmTokenRequest):
    user = get_request_user(request)
    return await user_service.update_fcm_token(
        user["role"], user.get("sub"), body.fcm_token
    )
