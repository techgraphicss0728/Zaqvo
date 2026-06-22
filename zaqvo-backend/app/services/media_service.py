"""Admin media uploads (delegates to catalog + storage)."""
from fastapi import UploadFile

from app.schemas.catalog import ProductUpdate


class MediaService:
    async def upload_product_image(
        self, *, product_id: str, file: UploadFile
    ) -> tuple[str, str]:
        from app.services.catalog_service import catalog_service
        from app.services.storage_service import storage_service

        await catalog_service.get_product(product_id, admin=True)
        key, url = await storage_service.upload_product_image(product_id=product_id, file=file)
        await catalog_service.update_product(
            product_id,
            ProductUpdate(image_key=key, image_url=url),
        )
        return key, url


media_service = MediaService()
