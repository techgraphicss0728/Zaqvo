"""S3 storage service for product image uploads."""
from __future__ import annotations

from urllib.parse import quote

import boto3
import structlog
from botocore.exceptions import BotoCoreError, ClientError
from fastapi import HTTPException, UploadFile

from app.core.config import settings

logger = structlog.get_logger(__name__)


class StorageService:
    def __init__(self) -> None:
        self._allowed_mime_types = {
            m.strip().lower()
            for m in settings.S3_ALLOWED_IMAGE_MIME_TYPES.split(",")
            if m.strip()
        }

    def _client(self):
        kwargs: dict[str, str] = {"region_name": settings.S3_REGION}
        if settings.S3_ACCESS_KEY_ID and settings.S3_SECRET_ACCESS_KEY:
            kwargs["aws_access_key_id"] = settings.S3_ACCESS_KEY_ID
            kwargs["aws_secret_access_key"] = settings.S3_SECRET_ACCESS_KEY
        if settings.S3_ENDPOINT_URL:
            kwargs["endpoint_url"] = settings.S3_ENDPOINT_URL
        return boto3.client("s3", **kwargs)

    def _assert_ready(self) -> None:
        if not settings.S3_BUCKET_NAME:
            raise HTTPException(status_code=500, detail="S3 bucket is not configured")

    def _assert_file_allowed(self, file: UploadFile, raw: bytes) -> None:
        if not raw:
            raise HTTPException(status_code=400, detail="Uploaded file is empty")
        if len(raw) > settings.S3_UPLOAD_MAX_BYTES:
            raise HTTPException(status_code=413, detail="File is too large")
        ctype = (file.content_type or "").lower().strip()
        if self._allowed_mime_types and ctype not in self._allowed_mime_types:
            raise HTTPException(status_code=400, detail="Unsupported file type")

    @staticmethod
    def _sanitize_name(name: str) -> str:
        cleaned = name.replace("\\", "_").replace("/", "_").strip()
        return cleaned or "upload.bin"

    def _public_url(self, key: str) -> str:
        if settings.S3_PUBLIC_URL_BASE:
            base = settings.S3_PUBLIC_URL_BASE.rstrip("/")
            return f"{base}/{quote(key)}"
        region = settings.S3_REGION
        bucket = settings.S3_BUCKET_NAME
        return f"https://{bucket}.s3.{region}.amazonaws.com/{quote(key)}"

    def presigned_get_url(self, key: str, *, expires: int | None = None) -> str:
        """Temporary read URL for private bucket objects (used in API responses)."""
        self._assert_ready()
        ttl = expires if expires is not None else settings.S3_PRESIGNED_URL_EXPIRES_SECONDS
        try:
            return self._client().generate_presigned_url(
                "get_object",
                Params={"Bucket": settings.S3_BUCKET_NAME, "Key": key},
                ExpiresIn=ttl,
            )
        except (BotoCoreError, ClientError) as exc:
            error_code, error_message = self._aws_error_info(exc)
            logger.warning(
                "s3_presign_failed",
                bucket=settings.S3_BUCKET_NAME,
                key=key,
                aws_error_code=error_code,
                aws_error_message=error_message,
            )
            return self._public_url(key)

    @staticmethod
    def _aws_error_info(exc: BotoCoreError | ClientError) -> tuple[str | None, str | None]:
        if isinstance(exc, ClientError):
            err = exc.response.get("Error", {})
            return err.get("Code"), err.get("Message")
        return type(exc).__name__, str(exc)

    def _raise_storage_error(
        self,
        *,
        action: str,
        key: str,
        exc: BotoCoreError | ClientError,
    ) -> None:
        error_code, error_message = self._aws_error_info(exc)
        logger.error(
            "s3_operation_failed",
            action=action,
            bucket=settings.S3_BUCKET_NAME,
            key=key,
            aws_error_code=error_code,
            aws_error_message=error_message,
        )
        detail = "Failed to upload image to storage"
        if settings.DEBUG and error_code:
            detail = f"{detail} ({error_code})"
        raise HTTPException(status_code=502, detail=detail) from exc

    async def upload_product_image(
        self,
        *,
        product_id: str,
        file: UploadFile,
    ) -> tuple[str, str]:
        self._assert_ready()
        body = await file.read()
        self._assert_file_allowed(file, body)
        filename = self._sanitize_name(file.filename or "upload.bin")
        key = f"products/{product_id}/{filename}"
        try:
            self._client().put_object(
                Bucket=settings.S3_BUCKET_NAME,
                Key=key,
                Body=body,
                ContentType=file.content_type or "application/octet-stream",
            )
        except (BotoCoreError, ClientError) as exc:
            self._raise_storage_error(action="put_object", key=key, exc=exc)
        return key, self._public_url(key)

    def delete_object(self, key: str) -> None:
        self._assert_ready()
        try:
            self._client().delete_object(Bucket=settings.S3_BUCKET_NAME, Key=key)
        except (BotoCoreError, ClientError) as exc:
            error_code, error_message = self._aws_error_info(exc)
            logger.warning(
                "s3_operation_failed",
                action="delete_object",
                bucket=settings.S3_BUCKET_NAME,
                key=key,
                aws_error_code=error_code,
                aws_error_message=error_message,
            )
            raise


storage_service = StorageService()
