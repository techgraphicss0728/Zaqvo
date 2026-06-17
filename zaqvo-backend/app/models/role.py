"""Dashboard role documents stored in MongoDB ``roles`` collection."""
from datetime import datetime
from typing import Any, Optional

from pydantic import BaseModel, ConfigDict, Field

from app.schemas.common import NameStr, NonEmptyStr


class RoleBase(BaseModel):
    name: NameStr
    slug: NonEmptyStr
    description: str = ""
    is_system: bool = False
    permissions: dict[str, Any] = Field(default_factory=dict)


class RoleInDB(RoleBase):
    model_config = ConfigDict(populate_by_name=True)

    id: Optional[str] = Field(alias="_id", default=None)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
