"""Customer: browse categories and active products (middleware enforces customer role)."""
from fastapi import APIRouter, Query

from app.schemas.catalog import CategoryResponse, ProductResponse
from app.schemas.common import PaginatedResponse
from app.services.catalog_service import catalog_service

router = APIRouter()


@router.get("/categories", response_model=PaginatedResponse[CategoryResponse])
async def customer_list_categories(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    search: str | None = Query(None, max_length=200),
):
    return await catalog_service.list_categories(
        page=page,
        limit=limit,
        search=search,
        is_active=True,
    )


@router.get("/products", response_model=PaginatedResponse[ProductResponse])
async def customer_list_products(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    search: str | None = Query(None, max_length=200),
    category_id: str | None = Query(None),
    min_price: float | None = Query(None, ge=0),
    max_price: float | None = Query(None, ge=0),
):
    return await catalog_service.list_products_customer(
        page=page,
        limit=limit,
        search=search,
        category_id=category_id,
        min_price=min_price,
        max_price=max_price,
    )


@router.get("/products/{product_id}", response_model=ProductResponse)
async def customer_get_product(product_id: str):
    return await catalog_service.get_product(product_id, admin=False)
