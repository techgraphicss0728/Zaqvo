"""
Dashboard role enums — seeded system roles and assignability rules.

Custom roles created by super admin use auto-generated slugs and are stored in MongoDB too.
"""
from __future__ import annotations

from enum import StrEnum
from typing import TypedDict


class DashboardRole(StrEnum):
    SUPER_ADMIN = "SUPER_ADMIN"
    ADMIN = "ADMIN"
    STORE_MANAGER = "STORE_MANAGER"
    INVENTORY_MANAGER = "INVENTORY_MANAGER"
    DELIVERY_MANAGER = "DELIVERY_MANAGER"
    SUPPORT_EXECUTIVE = "SUPPORT_EXECUTIVE"
    FINANCE_MANAGER = "FINANCE_MANAGER"
    CUSTOMER = "CUSTOMER"


class RoleDefinition(TypedDict):
    label: str
    description: str
    """Whether super admin can assign this role when adding dashboard users."""
    dashboard_assignable: bool


ROLE_DEFINITIONS: dict[DashboardRole, RoleDefinition] = {
    DashboardRole.SUPER_ADMIN: {
        "label": "Super Admin",
        "description": "Full access to all dashboard pages, users, and privileges",
        "dashboard_assignable": False,
    },
    DashboardRole.ADMIN: {
        "label": "Admin",
        "description": "Broad operational access across the dashboard",
        "dashboard_assignable": True,
    },
    DashboardRole.STORE_MANAGER: {
        "label": "Store Manager",
        "description": "Store operations — orders, catalog, and coupons",
        "dashboard_assignable": True,
    },
    DashboardRole.INVENTORY_MANAGER: {
        "label": "Inventory Manager",
        "description": "Categories, products, and stock-related screens",
        "dashboard_assignable": True,
    },
    DashboardRole.DELIVERY_MANAGER: {
        "label": "Delivery Manager",
        "description": "Orders, drivers, and delivery approvals",
        "dashboard_assignable": True,
    },
    DashboardRole.SUPPORT_EXECUTIVE: {
        "label": "Support Executive",
        "description": "Customer support — approvals, ratings, and feedbacks",
        "dashboard_assignable": True,
    },
    DashboardRole.FINANCE_MANAGER: {
        "label": "Finance Manager",
        "description": "Payments, collections, and financial reports",
        "dashboard_assignable": True,
    },
    DashboardRole.CUSTOMER: {
        "label": "Customer",
        "description": "End-customer role (mobile app — not a dashboard login role)",
        "dashboard_assignable": False,
    },
}

# Slugs that must never appear in assign-role dropdowns.
NON_ASSIGNABLE_ROLE_SLUGS: frozenset[str] = frozenset(
    {DashboardRole.SUPER_ADMIN.value, DashboardRole.CUSTOMER.value}
)

# Hidden from dashboard roles list (mobile-app only).
DASHBOARD_HIDDEN_ROLE_SLUGS: frozenset[str] = frozenset({DashboardRole.CUSTOMER.value})


def is_super_admin_role(slug: str | None) -> bool:
    return slug == DashboardRole.SUPER_ADMIN


def is_dashboard_assignable(slug: str | None, *, is_active: bool = True) -> bool:
    if not slug or slug in NON_ASSIGNABLE_ROLE_SLUGS:
        return False
    if not is_active:
        return False
    return True
