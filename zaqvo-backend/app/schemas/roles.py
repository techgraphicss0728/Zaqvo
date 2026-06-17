"""Role management request/response schemas."""
from datetime import datetime
from typing import Any

from pydantic import BaseModel, Field

from app.schemas.common import NameStr, PaginatedResponse
from app.schemas.permissions import PagePermissionDto


class RoleSummaryResponse(BaseModel):
    id: str
    name: str
    slug: str
    description: str = ""
    is_system: bool = False
    is_active: bool = True


class RoleDetailResponse(RoleSummaryResponse):
    permissions: dict[str, PagePermissionDto] = Field(default_factory=dict)
    created_at: datetime
    updated_at: datetime


class RoleListResponse(PaginatedResponse[RoleSummaryResponse]):
    pass


class RoleCreateRequest(BaseModel):
    name: NameStr
    description: str = ""


class RoleUpdateRequest(BaseModel):
    name: NameStr | None = None
    description: str | None = None
    is_active: bool | None = None


class RolePermissionsUpdateRequest(BaseModel):
    permissions: dict[str, Any]
