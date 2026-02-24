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

    SECRET_KEY: str = "change-me-in-production"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # SMS / BSNL bulk SMS settings
    BSNL_SMS_API_URL: str = "https://bulksms.bsnl.in:5010/api/Send_SMS"
    BSNL_SMS_HEADER: str = "EDTKIO"
    BSNL_ENTITY_ID: str = "1401406300000046832"
    BSNL_TEMPLATE_ID: str = "1407176362687428295"
    BSNL_AUTH_TOKEN: str = ""
    SMS_SENDER_NAME: str = "Zaqvo"

    CORS_ORIGINS: str = "http://localhost:3000,http://localhost:5173"
    RATE_LIMIT_PER_MINUTE: int = 120


settings = Settings()
