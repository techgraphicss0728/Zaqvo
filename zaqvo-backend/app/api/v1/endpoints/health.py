"""Extra health/readiness for API (optional)."""
from fastapi import APIRouter

router = APIRouter()


@router.get("")
async def api_health():
    return {"api": "v1", "status": "ok"}
