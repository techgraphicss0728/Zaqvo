"""Users CRUD and profile (placeholder)."""
from fastapi import APIRouter, Depends, HTTPException, Request

from app.api.deps import get_current_user_optional
from app.core.limiter import limiter
from app.models.user import UserResponse

router = APIRouter()


@router.get("/me", response_model=UserResponse)
@limiter.limit("60/minute")
async def me(request: Request, current_user=Depends(get_current_user_optional)):
    from datetime import datetime
    if not current_user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    # TODO: return real user from DB
    sub = current_user.get("sub", "")
    return UserResponse(
        id="1",
        email=sub if "@" in sub else f"{sub}@placeholder.local",
        full_name=None,
        role="customer",
        created_at=datetime.utcnow(),
    )
