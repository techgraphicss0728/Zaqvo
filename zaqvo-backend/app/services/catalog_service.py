"""Category and product persistence (MongoDB)."""
from datetime import datetime
from typing import Any

from bson import ObjectId
from bson.errors import InvalidId
from fastapi import HTTPException
from motor.motor_asyncio import AsyncIOMotorDatabase

from app.core import cache
from app.core.config import settings
from app.db.mongodb import get_db
from app.schemas.catalog import (
    CategoryCreate,
    CategoryResponse,
    CategoryUpdate,
    ProductCreate,
    ProductResponse,
    ProductUpdate,
    slug_or_derive,
)
from app.schemas.common import PaginatedResponse


async def _bump_catalog_cache() -> None:
    await cache.bump_catalog_epoch()


def _queue_delete_s3_object(key: str) -> None:
    from app.workers.storage import delete_s3_object

    delete_s3_object.delay(key)


def _db() -> AsyncIOMotorDatabase:
    db = get_db()
    if db is None:
        raise HTTPException(status_code=500, detail="Database not initialized")
    return db


def _oid(s: str) -> ObjectId:
    try:
        return ObjectId(s)
    except InvalidId as e:
        raise HTTPException(status_code=400, detail="Invalid id") from e


def _category_doc_to_response(doc: dict) -> CategoryResponse:
    return CategoryResponse(
        id=str(doc["_id"]),
        name=doc["name"],
        slug=doc["slug"],
        description=doc.get("description"),
        is_active=bool(doc.get("is_active", True)),
        created_at=doc["created_at"],
        updated_at=doc["updated_at"],
    )


def _product_doc_to_response(doc: dict, category_name: str | None = None) -> ProductResponse:
    stock = int(doc.get("stock", 0) or 0)
    out_of_stock = bool(doc.get("out_of_stock", False)) or stock <= 0
    return ProductResponse(
        id=str(doc["_id"]),
        category_id=str(doc["category_id"]),
        category_name=category_name,
        name=doc["name"],
        slug=doc["slug"],
        description=doc.get("description"),
        price=float(doc["price"]),
        image_url=doc.get("image_url"),
        image_key=doc.get("image_key"),
        stock=0 if out_of_stock else max(stock, 0),
        out_of_stock=out_of_stock,
        is_active=bool(doc.get("is_active", True)),
        created_at=doc["created_at"],
        updated_at=doc["updated_at"],
    )


async def _category_names_map(db: AsyncIOMotorDatabase, ids: list[ObjectId]) -> dict[str, str]:
    if not ids:
        return {}
    cursor = db["categories"].find({"_id": {"$in": ids}}, {"name": 1})
    out: dict[str, str] = {}
    async for c in cursor:
        out[str(c["_id"])] = c.get("name", "")
    return out


class CatalogService:
    async def create_category(self, body: CategoryCreate) -> CategoryResponse:
        db = _db()
        col = db["categories"]
        now = datetime.utcnow()
        slug = slug_or_derive(body.name, body.slug)
        existing = await col.find_one({"slug": slug})
        if existing:
            raise HTTPException(status_code=409, detail="Category slug already exists")
        doc = {
            "name": body.name.strip(),
            "slug": slug,
            "description": body.description.strip() if body.description else None,
            "is_active": True,
            "created_at": now,
            "updated_at": now,
        }
        r = await col.insert_one(doc)
        doc["_id"] = r.inserted_id
        await _bump_catalog_cache()
        return _category_doc_to_response(doc)

    def _category_filter(
        self,
        *,
        search: str | None,
        is_active: bool | None,
    ) -> dict[str, Any]:
        q: dict[str, Any] = {}
        if is_active is not None:
            q["is_active"] = is_active
        if search and search.strip():
            rx = search.strip()
            q["$or"] = [
                {"name": {"$regex": rx, "$options": "i"}},
                {"slug": {"$regex": rx, "$options": "i"}},
            ]
        return q

    async def list_categories(
        self,
        *,
        page: int,
        limit: int,
        search: str | None = None,
        is_active: bool | None = None,
    ) -> PaginatedResponse[CategoryResponse]:
        use_cache = settings.CACHE_ENABLED and is_active is not None
        if use_cache:
            epoch = await cache.get_catalog_epoch()
            cache_key = (
                f"zaqvo:categories:{epoch}:{page}:{limit}:{search or ''}:{is_active}"
            )
            hit = await cache.cache_get_json(cache_key)
            if hit is not None:
                return PaginatedResponse[CategoryResponse].model_validate(hit)

        db = _db()
        col = db["categories"]
        filt = self._category_filter(search=search, is_active=is_active)
        total = await col.count_documents(filt)
        skip = (page - 1) * limit
        cursor = col.find(filt).sort("name", 1).skip(skip).limit(limit)
        items: list[CategoryResponse] = []
        async for doc in cursor:
            items.append(_category_doc_to_response(doc))
        pages = (total + limit - 1) // limit if total else 0
        result = PaginatedResponse(
            items=items, total=total, page=page, limit=limit, pages=pages
        )
        if use_cache:
            epoch = await cache.get_catalog_epoch()
            cache_key = (
                f"zaqvo:categories:{epoch}:{page}:{limit}:{search or ''}:{is_active}"
            )
            await cache.cache_set_json(
                cache_key,
                result.model_dump(mode="json"),
                settings.CACHE_TTL_SECONDS,
            )
        return result

    async def get_category(self, category_id: str) -> CategoryResponse:
        db = _db()
        doc = await db["categories"].find_one({"_id": _oid(category_id)})
        if not doc:
            raise HTTPException(status_code=404, detail="Category not found")
        return _category_doc_to_response(doc)

    async def update_category(self, category_id: str, body: CategoryUpdate) -> CategoryResponse:
        db = _db()
        col = db["categories"]
        oid = _oid(category_id)
        existing = await col.find_one({"_id": oid})
        if not existing:
            raise HTTPException(status_code=404, detail="Category not found")
        updates: dict[str, Any] = {"updated_at": datetime.utcnow()}
        if body.name is not None:
            updates["name"] = body.name.strip()
        if body.slug is not None:
            nm = updates.get("name", existing["name"])
            updates["slug"] = slug_or_derive(nm, body.slug)
        if body.description is not None:
            updates["description"] = body.description.strip() if body.description else None
        if body.is_active is not None:
            updates["is_active"] = body.is_active
        if "slug" in updates:
            clash = await col.find_one({"slug": updates["slug"], "_id": {"$ne": oid}})
            if clash:
                raise HTTPException(status_code=409, detail="Category slug already exists")
        if not any(k != "updated_at" for k in updates):
            return _category_doc_to_response(existing)
        await col.update_one({"_id": oid}, {"$set": updates})
        doc = await col.find_one({"_id": oid})
        assert doc
        await _bump_catalog_cache()
        return _category_doc_to_response(doc)

    async def delete_category(self, category_id: str) -> None:
        db = _db()
        oid = _oid(category_id)
        n = await db["products"].count_documents({"category_id": oid})
        if n > 0:
            raise HTTPException(
                status_code=400,
                detail="Cannot delete category with existing products",
            )
        r = await db["categories"].delete_one({"_id": oid})
        if r.deleted_count == 0:
            raise HTTPException(status_code=404, detail="Category not found")
        await _bump_catalog_cache()

    async def create_product(self, body: ProductCreate) -> ProductResponse:
        db = _db()
        cat_oid = _oid(body.category_id)
        cat = await db["categories"].find_one({"_id": cat_oid})
        if not cat:
            raise HTTPException(status_code=400, detail="Category not found")
        col = db["products"]
        now = datetime.utcnow()
        slug = slug_or_derive(body.name, body.slug)
        dup = await col.find_one({"slug": slug})
        if dup:
            raise HTTPException(status_code=409, detail="Product slug already exists")
        stock = max(int(body.stock), 0)
        out_of_stock = bool(body.out_of_stock) or stock <= 0
        doc = {
            "category_id": cat_oid,
            "name": body.name.strip(),
            "slug": slug,
            "description": body.description.strip() if body.description else None,
            "price": float(body.price),
            "image_url": body.image_url.strip() if body.image_url else None,
            "image_key": body.image_key.strip() if body.image_key else None,
            "stock": 0 if out_of_stock else stock,
            "out_of_stock": out_of_stock,
            "is_active": True,
            "created_at": now,
            "updated_at": now,
        }
        r = await col.insert_one(doc)
        doc["_id"] = r.inserted_id
        await _bump_catalog_cache()
        return _product_doc_to_response(doc, category_name=cat.get("name"))

    def _product_filter(
        self,
        *,
        search: str | None,
        category_id: str | None,
        min_price: float | None,
        max_price: float | None,
        is_active: bool | None,
        only_active: bool,
    ) -> dict[str, Any]:
        q: dict[str, Any] = {}
        if only_active:
            q["is_active"] = True
        elif is_active is not None:
            q["is_active"] = is_active
        if category_id:
            q["category_id"] = _oid(category_id)
        if min_price is not None:
            q.setdefault("price", {})["$gte"] = float(min_price)
        if max_price is not None:
            q.setdefault("price", {})["$lte"] = float(max_price)
        if search and search.strip():
            rx = search.strip()
            q["$or"] = [
                {"name": {"$regex": rx, "$options": "i"}},
                {"slug": {"$regex": rx, "$options": "i"}},
                {"description": {"$regex": rx, "$options": "i"}},
            ]
        return q

    async def list_products_admin(
        self,
        *,
        page: int,
        limit: int,
        search: str | None = None,
        category_id: str | None = None,
        min_price: float | None = None,
        max_price: float | None = None,
        is_active: bool | None = None,
    ) -> PaginatedResponse[ProductResponse]:
        db = _db()
        col = db["products"]
        filt = self._product_filter(
            search=search,
            category_id=category_id,
            min_price=min_price,
            max_price=max_price,
            is_active=is_active,
            only_active=False,
        )
        total = await col.count_documents(filt)
        skip = (page - 1) * limit
        cursor = col.find(filt).sort("name", 1).skip(skip).limit(limit)
        docs: list[dict] = []
        async for doc in cursor:
            docs.append(doc)
        cat_ids = list({d["category_id"] for d in docs})
        names = await _category_names_map(db, cat_ids)
        items = [
            _product_doc_to_response(d, category_name=names.get(str(d["category_id"])))
            for d in docs
        ]
        pages = (total + limit - 1) // limit if total else 0
        return PaginatedResponse(items=items, total=total, page=page, limit=limit, pages=pages)

    async def list_products_customer(
        self,
        *,
        page: int,
        limit: int,
        search: str | None = None,
        category_id: str | None = None,
        min_price: float | None = None,
        max_price: float | None = None,
    ) -> PaginatedResponse[ProductResponse]:
        if settings.CACHE_ENABLED:
            epoch = await cache.get_catalog_epoch()
            cache_key = (
                f"zaqvo:products:customer:{epoch}:{page}:{limit}:"
                f"{search or ''}:{category_id or ''}:{min_price}:{max_price}"
            )
            hit = await cache.cache_get_json(cache_key)
            if hit is not None:
                return PaginatedResponse[ProductResponse].model_validate(hit)

        db = _db()
        col = db["products"]
        filt = self._product_filter(
            search=search,
            category_id=category_id,
            min_price=min_price,
            max_price=max_price,
            is_active=None,
            only_active=True,
        )
        total = await col.count_documents(filt)
        skip = (page - 1) * limit
        cursor = col.find(filt).sort("name", 1).skip(skip).limit(limit)
        docs: list[dict] = []
        async for doc in cursor:
            docs.append(doc)
        cat_ids = list({d["category_id"] for d in docs})
        names = await _category_names_map(db, cat_ids)
        items = [
            _product_doc_to_response(d, category_name=names.get(str(d["category_id"])))
            for d in docs
        ]
        pages = (total + limit - 1) // limit if total else 0
        result = PaginatedResponse(
            items=items, total=total, page=page, limit=limit, pages=pages
        )
        if settings.CACHE_ENABLED:
            epoch = await cache.get_catalog_epoch()
            cache_key = (
                f"zaqvo:products:customer:{epoch}:{page}:{limit}:"
                f"{search or ''}:{category_id or ''}:{min_price}:{max_price}"
            )
            await cache.cache_set_json(
                cache_key,
                result.model_dump(mode="json"),
                settings.CACHE_TTL_SECONDS,
            )
        return result

    async def get_product(self, product_id: str, *, admin: bool) -> ProductResponse:
        db = _db()
        doc = await db["products"].find_one({"_id": _oid(product_id)})
        if not doc:
            raise HTTPException(status_code=404, detail="Product not found")
        if not admin and not doc.get("is_active", True):
            raise HTTPException(status_code=404, detail="Product not found")
        cat = await db["categories"].find_one({"_id": doc["category_id"]})
        cn = cat.get("name") if cat else None
        return _product_doc_to_response(doc, category_name=cn)

    async def update_product(self, product_id: str, body: ProductUpdate) -> ProductResponse:
        db = _db()
        col = db["products"]
        oid = _oid(product_id)
        existing = await col.find_one({"_id": oid})
        if not existing:
            raise HTTPException(status_code=404, detail="Product not found")
        old_image_key = existing.get("image_key")
        updates: dict[str, Any] = {"updated_at": datetime.utcnow()}
        if body.category_id is not None:
            coid = _oid(body.category_id)
            cat = await db["categories"].find_one({"_id": coid})
            if not cat:
                raise HTTPException(status_code=400, detail="Category not found")
            updates["category_id"] = coid
        if body.name is not None:
            updates["name"] = body.name.strip()
        if body.slug is not None:
            nm = updates.get("name", existing["name"])
            updates["slug"] = slug_or_derive(nm, body.slug)
        if body.description is not None:
            updates["description"] = body.description.strip() if body.description else None
        if body.price is not None:
            updates["price"] = float(body.price)
        if body.image_url is not None:
            updates["image_url"] = body.image_url.strip() if body.image_url else None
        if body.image_key is not None:
            updates["image_key"] = body.image_key.strip() if body.image_key else None
        if body.stock is not None:
            updates["stock"] = max(int(body.stock), 0)
            if updates["stock"] <= 0:
                updates["out_of_stock"] = True
        if body.out_of_stock is not None:
            updates["out_of_stock"] = bool(body.out_of_stock)
            if body.out_of_stock:
                updates["stock"] = 0
        if body.is_active is not None:
            updates["is_active"] = body.is_active
        if "slug" in updates:
            clash = await col.find_one({"slug": updates["slug"], "_id": {"$ne": oid}})
            if clash:
                raise HTTPException(status_code=409, detail="Product slug already exists")
        if not any(k != "updated_at" for k in updates):
            cat = await db["categories"].find_one({"_id": existing["category_id"]})
            return _product_doc_to_response(existing, category_name=cat.get("name") if cat else None)
        await col.update_one({"_id": oid}, {"$set": updates})
        doc = await col.find_one({"_id": oid})
        assert doc
        new_image_key = doc.get("image_key")
        if old_image_key and new_image_key != old_image_key:
            _queue_delete_s3_object(old_image_key)
        cat = await db["categories"].find_one({"_id": doc["category_id"]})
        await _bump_catalog_cache()
        return _product_doc_to_response(doc, category_name=cat.get("name") if cat else None)

    async def delete_product(self, product_id: str) -> None:
        db = _db()
        oid = _oid(product_id)
        existing = await db["products"].find_one({"_id": oid})
        if not existing:
            raise HTTPException(status_code=404, detail="Product not found")
        r = await db["products"].delete_one({"_id": oid})
        if r.deleted_count == 0:
            raise HTTPException(status_code=404, detail="Product not found")
        image_key = existing.get("image_key")
        if image_key:
            _queue_delete_s3_object(image_key)
        await _bump_catalog_cache()


catalog_service = CatalogService()
