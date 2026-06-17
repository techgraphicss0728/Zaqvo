"""Role and privilege management endpoints (super admin)."""
from fastapi import APIRouter, Query, Request

from app.api.deps import ensure_super_admin, get_request_user
from app.core.limiter import limiter
from app.schemas.permissions import PermissionCatalogResponse
from app.core.role_enums import ROLE_DEFINITIONS, DashboardRole
from app.schemas.roles import (
    RoleCreateRequest,
    RoleDetailResponse,
    RoleListResponse,
    RolePermissionsUpdateRequest,
    RoleSummaryResponse,
    RoleUpdateRequest,
)
from app.services.role_service import role_service

router = APIRouter()


@router.get("/roles/permissions-catalog", response_model=PermissionCatalogResponse)
@limiter.limit("60/minute")
async def get_permissions_catalog(request: Request):
    user = get_request_user(request)
    ensure_super_admin(user)
    return await role_service.get_permissions_catalog()


@router.get("/roles/assignable", response_model=list[RoleSummaryResponse])
@limiter.limit("60/minute")
async def list_assignable_roles(request: Request):
    user = get_request_user(request)
    ensure_super_admin(user)
    return await role_service.list_assignable_roles()


@router.get("/roles/enums")
@limiter.limit("60/minute")
async def list_role_enums(request: Request):
    """Return all ``DashboardRole`` values for UI dropdowns and labels."""
    user = get_request_user(request)
    ensure_super_admin(user)

    return [
        {
            "slug": role.value,
            "label": ROLE_DEFINITIONS[role]["label"],
            "description": ROLE_DEFINITIONS[role]["description"],
            "dashboard_assignable": ROLE_DEFINITIONS[role]["dashboard_assignable"],
        }
        for role in DashboardRole
    ]


@router.get("/roles", response_model=RoleListResponse)
@limiter.limit("60/minute")
async def list_roles(
    request: Request,
    page: int = Query(1, ge=1),
    limit: int = Query(10, ge=1, le=100),
):
    user = get_request_user(request)
    ensure_super_admin(user)
    return await role_service.list_roles_paginated(page=page, limit=limit)


@router.get("/roles/{role_id}", response_model=RoleDetailResponse)
@limiter.limit("60/minute")
async def get_role(request: Request, role_id: str):
    user = get_request_user(request)
    ensure_super_admin(user)
    return await role_service.get_role(role_id)


@router.post("/roles", response_model=RoleDetailResponse)
@limiter.limit("20/minute")
async def create_role(request: Request, body: RoleCreateRequest):
    user = get_request_user(request)
    ensure_super_admin(user)
    return await role_service.create_role(body)


@router.patch("/roles/{role_id}", response_model=RoleDetailResponse)
@limiter.limit("30/minute")
async def update_role(request: Request, role_id: str, body: RoleUpdateRequest):
    user = get_request_user(request)
    ensure_super_admin(user)
    return await role_service.update_role(role_id, body)


@router.delete("/roles/{role_id}", status_code=204)
@limiter.limit("20/minute")
async def delete_role(request: Request, role_id: str):
    user = get_request_user(request)
    ensure_super_admin(user)
    await role_service.delete_role(role_id)


@router.put("/roles/{role_id}/permissions", response_model=RoleDetailResponse)
@limiter.limit("30/minute")
async def update_role_permissions(
    request: Request,
    role_id: str,
    body: RolePermissionsUpdateRequest,
):
    user = get_request_user(request)
    ensure_super_admin(user)
    return await role_service.update_permissions(role_id, body)
