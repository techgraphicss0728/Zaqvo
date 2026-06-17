"""S3 storage service for product image uploads."""
from __future__ import annotations

from urllib.parse import quote

import boto3
from botocore.exceptions import BotoCoreError, ClientError
from fastapi import HTTPException, UploadFile

from app.core.config import settings


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
            raise HTTPException(status_code=502, detail="Failed to upload image to storage") from exc
        return key, self._public_url(key)

    def delete_object(self, key: str) -> None:
        self._assert_ready()
        try:
            self._client().delete_object(Bucket=settings.S3_BUCKET_NAME, Key=key)
        except (BotoCoreError, ClientError):
            # best effort; caller can queue background retry
            raise


storage_service = StorageService()
