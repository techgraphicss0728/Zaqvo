"""
Dashboard permission catalog — single source of truth for pages and actions.

Add new dashboard screens here; roles store permissions keyed by ``page_key``.
"""
from __future__ import annotations

from typing import Literal, TypedDict

PermissionAction = Literal["view", "add", "edit", "delete"]

# Standard CRUD actions shown on the privileges matrix.
STANDARD_ACTIONS: tuple[PermissionAction, ...] = ("view", "add", "edit", "delete")


class PageDefinition(TypedDict):
    key: str
    label: str
    path: str
    # Optional button-level keys (e.g. export, approve) configurable per role.
    buttons: list[str]


DASHBOARD_PAGES: tuple[PageDefinition, ...] = (
    {"key": "home", "label": "Home", "path": "/", "buttons": ["export_report"]},
    {"key": "payments", "label": "Payments", "path": "/payments", "buttons": ["export"]},
    {"key": "collections", "label": "Collections", "path": "/collections", "buttons": []},
    {"key": "orders", "label": "Orders", "path": "/orders", "buttons": ["assign_driver", "cancel"]},
    {"key": "catalog", "label": "Categories", "path": "/catalog", "buttons": []},
    {"key": "products", "label": "Products", "path": "/products", "buttons": ["upload_image"]},
    {"key": "drivers", "label": "Drivers", "path": "/drivers", "buttons": ["verify"]},
    {"key": "approvals", "label": "Approvals", "path": "/approvals", "buttons": ["approve", "reject"]},
    {"key": "ratings", "label": "Ratings", "path": "/ratings", "buttons": []},
    {"key": "feedbacks", "label": "Feedbacks", "path": "/feedbacks", "buttons": ["reply"]},
    {"key": "coupons", "label": "Coupons", "path": "/coupons", "buttons": []},
    {"key": "users", "label": "Users", "path": "/users", "buttons": ["deactivate"]},
    {"key": "privileges", "label": "Privileges", "path": "/privileges", "buttons": []},
)

PAGE_KEYS: frozenset[str] = frozenset(p["key"] for p in DASHBOARD_PAGES)


def empty_page_permissions() -> dict[str, dict]:
    """Default deny-all permission map for a new role."""
    result: dict[str, dict] = {}
    for page in DASHBOARD_PAGES:
        result[page["key"]] = {
            "view": False,
            "add": False,
            "edit": False,
            "delete": False,
            "buttons": {btn: False for btn in page["buttons"]},
        }
    return result


def full_page_permissions() -> dict[str, dict]:
    """Allow-all permission map (super admin / bootstrap)."""
    result: dict[str, dict] = {}
    for page in DASHBOARD_PAGES:
        result[page["key"]] = {
            "view": True,
            "add": True,
            "edit": True,
            "delete": True,
            "buttons": {btn: True for btn in page["buttons"]},
        }
    return result
