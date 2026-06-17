"""Aggregates all v1 API routers."""
from fastapi import APIRouter

from app.api.v1.endpoints import (
    admin_catalog,
    admin_media,
    admin_roles,
    admin_users,
    auth,
    customer_catalog,
    health,
    users,
)

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(health.router, prefix="/health", tags=["health"])
api_router.include_router(admin_catalog.router, prefix="/admin", tags=["admin-catalog"])
api_router.include_router(admin_media.router, prefix="/admin", tags=["admin-media"])
api_router.include_router(admin_users.router, prefix="/admin", tags=["admin-users"])
api_router.include_router(admin_roles.router, prefix="/admin", tags=["admin-roles"])
api_router.include_router(
    customer_catalog.router, prefix="/customer", tags=["customer-catalog"]
)
