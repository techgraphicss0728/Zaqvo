"""Admin media endpoints for product image uploads."""
from fastapi import APIRouter, File, Request, UploadFile

from app.api.deps import ensure_catalog_upload_permission
from app.services.media_service import media_service

router = APIRouter()


@router.post("/products/{product_id}/image")
async def admin_upload_product_image(
    request: Request,
    product_id: str,
    file: UploadFile = File(...),
):
    await ensure_catalog_upload_permission(request)
    key, url = await media_service.upload_product_image(product_id=product_id, file=file)
    return {"ok": True, "key": key, "url": url}
