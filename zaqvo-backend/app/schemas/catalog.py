"""Categories and products (admin + customer)."""
from datetime import datetime

from pydantic import BaseModel, Field, field_validator

from app.schemas.common import NameStr, NonEmptyStr


def _slugify(s: str) -> str:
    import re

    s = s.lower().strip()
    s = re.sub(r"[^\w\s-]", "", s)
    s = re.sub(r"[-\s]+", "-", s)
    return s.strip("-") or "item"


class CategoryCreate(BaseModel):
    name: NameStr
    slug: str | None = Field(default=None, max_length=128)
    description: str | None = Field(default=None, max_length=2000)

    @field_validator("slug", mode="before")
    @classmethod
    def empty_slug_to_none(cls, v: str | None) -> str | None:
        if v is None or (isinstance(v, str) and not v.strip()):
            return None
        return v.strip()


class CategoryUpdate(BaseModel):
    name: NameStr | None = None
    slug: str | None = Field(default=None, max_length=128)
    description: str | None = Field(default=None, max_length=2000)
    is_active: bool | None = None


class CategoryResponse(BaseModel):
    id: str
    name: str
    slug: str
    description: str | None
    is_active: bool
    created_at: datetime
    updated_at: datetime


class ProductCreate(BaseModel):
    category_id: NonEmptyStr
    name: NameStr
    slug: str | None = Field(default=None, max_length=128)
    description: str | None = Field(default=None, max_length=5000)
    price: float = Field(..., gt=0, le=1_000_000_000)
    image_url: str | None = Field(default=None, max_length=2000)
    image_key: str | None = Field(default=None, max_length=2000)
    stock: int = Field(default=0, ge=0)
    out_of_stock: bool = False

    @field_validator("slug", mode="before")
    @classmethod
    def empty_slug_to_none(cls, v: str | None) -> str | None:
        if v is None or (isinstance(v, str) and not v.strip()):
            return None
        return v.strip()


class ProductUpdate(BaseModel):
    category_id: str | None = None
    name: NameStr | None = None
    slug: str | None = Field(default=None, max_length=128)
    description: str | None = Field(default=None, max_length=5000)
    price: float | None = Field(default=None, gt=0, le=1_000_000_000)
    is_active: bool | None = None
    image_url: str | None = Field(default=None, max_length=2000)
    image_key: str | None = Field(default=None, max_length=2000)
    stock: int | None = Field(default=None, ge=0)
    out_of_stock: bool | None = None


class ProductResponse(BaseModel):
    id: str
    category_id: str
    category_name: str | None = None
    name: str
    slug: str
    description: str | None
    price: float
    image_url: str | None = None
    image_key: str | None = None
    stock: int = 0
    out_of_stock: bool = False
    is_active: bool
    created_at: datetime
    updated_at: datetime


def slug_or_derive(name: str, slug: str | None) -> str:
    if slug:
        return _slugify(slug)
    return _slugify(name)
