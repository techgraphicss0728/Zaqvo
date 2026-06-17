"""Application configuration from environment."""
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    APP_ENV: str = "development"
    DEBUG: bool = False
    PROJECT_NAME: str = "Zaqvo API"
    API_V1_PREFIX: str = "/api/v1"

    MONGODB_URI: str = "mongodb://localhost:27017"
    MONGODB_DB_NAME: str = "zaqvo"

    REDIS_URL: str = "redis://localhost:6379/0"
    CELERY_BROKER_URL: str = "redis://localhost:6379/1"
    CACHE_ENABLED: bool = True
    CACHE_TTL_SECONDS: int = 60
    CATALOG_CACHE_EPOCH_KEY: str = "zaqvo:catalog:epoch"
    IDEMPOTENCY_KEY_PREFIX: str = "zaqvo:idempotency"
    USE_REDIS_RATE_LIMIT: bool = False

    SECRET_KEY: str = "change-me-in-production"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    AUTH_ACCESS_COOKIE_NAME: str = "zaqvo_access_token"
    AUTH_REFRESH_COOKIE_NAME: str = "zaqvo_refresh_token"
    AUTH_COOKIE_SECURE: bool = False
    AUTH_COOKIE_SAMESITE: str = "lax"
    SUPER_ADMIN_SETUP_KEY: str = ""
    # Bootstrap first super admin (mobile-only OTP login; seeded when no super admin exists)
    SUPER_ADMIN_MOBILE: str = ""
    SUPER_ADMIN_NAME: str = "Super Admin"

    # OTP (shared TTL for signup/login across all roles)
    OTP_TTL_MINUTES: int = 5

    # SMS / BSNL bulk SMS settings
    BSNL_SMS_API_URL: str = "https://bulksms.bsnl.in:5010/api/Send_SMS"
    BSNL_SMS_HEADER: str = "EDTKIO"
    BSNL_ENTITY_ID: str = "1401406300000046832"
    BSNL_TEMPLATE_ID: str = "1407176362687428295"
    BSNL_AUTH_TOKEN: str = ""
    SMS_SENDER_NAME: str = "Zaqvo"
    # Admin dashboard login OTP (separate BSNL header + DLT template)
    BSNL_ADMIN_SMS_HEADER: str = "BMDPAI"
    BSNL_ADMIN_LOGIN_TEMPLATE_ID: str = "1407172975491145102"

    CORS_ORIGINS: str = "http://localhost:3000,http://localhost:5173"
    RATE_LIMIT_PER_MINUTE: int = 120

    # S3 uploads
    S3_BUCKET_NAME: str = "zaqvo-uploads"
    S3_REGION: str = "ap-south-1"
    S3_ACCESS_KEY_ID: str = ""
    S3_SECRET_ACCESS_KEY: str = ""
    S3_ENDPOINT_URL: str | None = None
    S3_PUBLIC_URL_BASE: str | None = None
    S3_UPLOAD_MAX_BYTES: int = 5 * 1024 * 1024
    S3_ALLOWED_IMAGE_MIME_TYPES: str = "image/jpeg,image/png,image/webp"


settings = Settings()
