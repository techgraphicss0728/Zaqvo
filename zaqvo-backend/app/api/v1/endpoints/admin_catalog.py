"""Admin: categories and products (middleware enforces admin role)."""
from fastapi import APIRouter, Query, Request

from app.api.deps import ensure_super_admin, get_request_user
from app.schemas.catalog import (
    CategoryCreate,
    CategoryResponse,
    CategoryUpdate,
    ProductCreate,
    ProductResponse,
    ProductUpdate,
)
from app.schemas.common import PaginatedResponse
from app.services.catalog_service import catalog_service

router = APIRouter()


def _require_super_admin(request: Request) -> None:
    ensure_super_admin(get_request_user(request))


@router.post("/categories", response_model=CategoryResponse)
async def admin_create_category(request: Request, body: CategoryCreate):
    _require_super_admin(request)
    return await catalog_service.create_category(body)


@router.get("/categories", response_model=PaginatedResponse[CategoryResponse])
async def admin_list_categories(
    request: Request,
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    search: str | None = Query(None, max_length=200),
    is_active: bool | None = Query(None),
):
    _require_super_admin(request)
    return await catalog_service.list_categories(
        page=page,
        limit=limit,
        search=search,
        is_active=is_active,
    )


@router.get("/categories/{category_id}", response_model=CategoryResponse)
async def admin_get_category(request: Request, category_id: str):
    _require_super_admin(request)
    return await catalog_service.get_category(category_id)


@router.patch("/categories/{category_id}", response_model=CategoryResponse)
async def admin_update_category(request: Request, category_id: str, body: CategoryUpdate):
    _require_super_admin(request)
    return await catalog_service.update_category(category_id, body)


@router.delete("/categories/{category_id}")
async def admin_delete_category(request: Request, category_id: str):
    _require_super_admin(request)
    await catalog_service.delete_category(category_id)
    return {"ok": True}


@router.post("/products", response_model=ProductResponse)
async def admin_create_product(request: Request, body: ProductCreate):
    _require_super_admin(request)
    return await catalog_service.create_product(body)


@router.get("/products", response_model=PaginatedResponse[ProductResponse])
async def admin_list_products(
    request: Request,
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    search: str | None = Query(None, max_length=200),
    category_id: str | None = Query(None),
    min_price: float | None = Query(None, ge=0),
    max_price: float | None = Query(None, ge=0),
    is_active: bool | None = Query(None),
):
    _require_super_admin(request)
    return await catalog_service.list_products_admin(
        page=page,
        limit=limit,
        search=search,
        category_id=category_id,
        min_price=min_price,
        max_price=max_price,
        is_active=is_active,
    )


@router.get("/products/{product_id}", response_model=ProductResponse)
async def admin_get_product(request: Request, product_id: str):
    _require_super_admin(request)
    return await catalog_service.get_product(product_id, admin=True)


@router.patch("/products/{product_id}", response_model=ProductResponse)
async def admin_update_product(request: Request, product_id: str, body: ProductUpdate):
    _require_super_admin(request)
    return await catalog_service.update_product(product_id, body)


@router.delete("/products/{product_id}")
async def admin_delete_product(request: Request, product_id: str):
    _require_super_admin(request)
    await catalog_service.delete_product(product_id)
    return {"ok": True}
