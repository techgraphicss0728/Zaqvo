"""Permission DTOs returned to the dashboard."""
from pydantic import BaseModel, Field

from app.core.permissions_catalog import DASHBOARD_PAGES, STANDARD_ACTIONS


class PagePermissionDto(BaseModel):
    view: bool = False
    add: bool = False
    edit: bool = False
    delete: bool = False
    buttons: dict[str, bool] = Field(default_factory=dict)


class PermissionCatalogPageDto(BaseModel):
    key: str
    label: str
    path: str
    actions: list[str] = Field(default_factory=lambda: list(STANDARD_ACTIONS))
    buttons: list[str] = Field(default_factory=list)


class PermissionCatalogResponse(BaseModel):
    pages: list[PermissionCatalogPageDto] = Field(
        default_factory=lambda: [
            PermissionCatalogPageDto(
                key=p["key"],
                label=p["label"],
                path=p["path"],
                buttons=list(p["buttons"]),
            )
            for p in DASHBOARD_PAGES
        ]
    )
    actions: list[str] = Field(default_factory=lambda: list(STANDARD_ACTIONS))
