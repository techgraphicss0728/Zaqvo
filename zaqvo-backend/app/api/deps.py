"""Request helpers. JWT validation runs in AuthMiddleware; routes use request.state.user."""
from typing import Literal

from bson import ObjectId
from bson.errors import InvalidId
from fastapi import HTTPException, Request, status

from app.db.mongodb import get_db
from app.services.permission_service import permission_service


def get_request_user(request: Request) -> dict:
    """User dict from AuthMiddleware (sub, role, payload)."""
    user = getattr(request.state, "user", None)
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not authenticated")
    return user


def ensure_role(user: dict, expected: Literal["customer", "driver", "admin"]) -> None:
    if user.get("role") != expected:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden for this role")


def ensure_super_admin(user: dict) -> None:
    if user.get("role") != "admin":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admin role required")
    payload = user.get("payload") or {}
    if not bool(payload.get("is_super_admin", False)):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Super admin access required")


async def _resolve_admin_permissions(user: dict) -> dict:
    if user.get("role") != "admin":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admin role required")

    payload = user.get("payload") or {}
    if bool(payload.get("is_super_admin", False)):
        from app.core.permissions_catalog import full_page_permissions

        return full_page_permissions()

    admin_id = user.get("sub")
    if not admin_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Insufficient permissions")

    try:
        oid = ObjectId(admin_id)
    except InvalidId as exc:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Insufficient permissions") from exc

    db = get_db()
    if db is None:
        raise HTTPException(status_code=500, detail="Database not initialized")

    admin_doc = await db["admins"].find_one({"_id": oid})
    if not admin_doc or admin_doc.get("is_active") is False:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Insufficient permissions")

    return await permission_service.resolve_for_admin(admin_doc)


async def ensure_page_permission(
    request: Request,
    *,
    page_key: str,
    action: str | None = None,
    button_key: str | None = None,
) -> None:
    """Super admins bypass; others need matching role permissions."""
    user = get_request_user(request)
    permissions = await _resolve_admin_permissions(user)
    if permission_service.has_permission(
        permissions,
        page_key=page_key,
        action=action or "view",
        button_key=button_key,
    ):
        return
    raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Insufficient permissions")


async def ensure_catalog_upload_permission(request: Request) -> None:
    """Anyone who can add or edit catalog products may upload images."""
    user = get_request_user(request)
    permissions = await _resolve_admin_permissions(user)
    if permission_service.has_permission(permissions, page_key="catalog", action="add"):
        return
    if permission_service.has_permission(permissions, page_key="catalog", action="edit"):
        return
    if permission_service.has_permission(
        permissions, page_key="catalog", button_key="upload_image"
    ):
        return
    if permission_service.has_permission(
        permissions, page_key="products", button_key="upload_image"
    ):
        return
    raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Insufficient permissions")
