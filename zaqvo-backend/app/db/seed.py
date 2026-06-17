"""Bootstrap default roles and the first super admin on application startup."""
from __future__ import annotations

from datetime import datetime

import structlog

from app.core.config import settings
from app.core.role_enums import DashboardRole
from app.db.mongodb import get_db
from app.services.role_service import role_service

logger = structlog.get_logger(__name__)


async def seed_dashboard_defaults() -> None:
    """
    Idempotent startup seed:
    - All ``DashboardRole`` enum values in ``roles`` collection
    - First super admin from env when none exists
    """
    db = get_db()
    if db is None:
        return

    await role_service.seed_default_roles()
    await role_service.migrate_legacy_roles()
    await _migrate_legacy_admins(db)
    await _seed_super_admin_if_missing(db)


async def _migrate_legacy_admins(db) -> None:
    """Backfill fields added after first admin records were created."""
    now = datetime.utcnow()
    super_role = await db["roles"].find_one({"slug": DashboardRole.SUPER_ADMIN.value})

    await db["admins"].update_many(
        {"otp_verified": True, "is_active": {"$exists": False}},
        {"$set": {"is_active": True, "updated_at": now}},
    )

    if not super_role:
        return

    role_id = str(super_role["_id"])
    await db["admins"].update_many(
        {
            "is_super_admin": True,
            "$or": [
                {"role_slug": {"$exists": False}},
                {"role_id": {"$exists": False}},
            ],
        },
        {
            "$set": {
                "role_slug": DashboardRole.SUPER_ADMIN.value,
                "role_id": role_id,
                "role_name": super_role.get("name"),
                "updated_at": now,
            }
        },
    )


async def _seed_super_admin_if_missing(db) -> None:
    admins = db["admins"]
    existing = await admins.find_one({"is_super_admin": True})
    if existing:
        return

    mobile = settings.SUPER_ADMIN_MOBILE.strip()
    name = settings.SUPER_ADMIN_NAME.strip() or "Super Admin"
    if not mobile:
        logger.info("super_admin_seed_skipped", reason="SUPER_ADMIN_MOBILE not configured")
        return

    super_role = await db["roles"].find_one({"slug": DashboardRole.SUPER_ADMIN.value})
    if not super_role:
        logger.warning("super_admin_seed_skipped", reason="SUPER_ADMIN role missing")
        return

    now = datetime.utcnow()
    await admins.insert_one(
        {
            "name": name,
            "mobile_number": mobile,
            "otp_verified": True,
            "is_active": True,
            "is_super_admin": True,
            "role_id": str(super_role["_id"]),
            "role_slug": DashboardRole.SUPER_ADMIN.value,
            "role_name": super_role.get("name"),
            "password_hash": None,
            "created_by": None,
            "last_login": None,
            "created_at": now,
            "updated_at": now,
        }
    )
    logger.info("super_admin_seeded", mobile_suffix=mobile[-4:])
