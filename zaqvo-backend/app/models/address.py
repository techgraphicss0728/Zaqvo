from datetime import datetime
from typing import Optional, Literal, Tuple

from pydantic import BaseModel, Field, ConfigDict, field_validator


class GeoPoint(BaseModel):
    """GeoJSON Point for storing coordinates in MongoDB."""

    type: Literal["Point"] = "Point"
    coordinates: Tuple[float, float] = Field(
        ...,
        description="Longitude, latitude",
        min_length=2,
        max_length=2,
    )

    @field_validator("coordinates")
    @classmethod
    def validate_coordinates(cls, v: Tuple[float, float]) -> Tuple[float, float]:
        lon, lat = v
        if not (-180.0 <= lon <= 180.0):
            raise ValueError("Longitude must be between -180 and 180")
        if not (-90.0 <= lat <= 90.0):
            raise ValueError("Latitude must be between -90 and 90")
        return v


class Address(BaseModel):
    """Address document stored in the `addresses` collection."""

    model_config = ConfigDict(populate_by_name=True)

    id: Optional[str] = Field(alias="_id", default=None)

    user_id: str
    user_type: str  # customer | driver | admin

    label: Optional[str] = None
    address: str
    landmark: Optional[str] = None

    location: GeoPoint

    place_id: Optional[str] = None
    is_default: bool = False

    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: Optional[datetime] = None

