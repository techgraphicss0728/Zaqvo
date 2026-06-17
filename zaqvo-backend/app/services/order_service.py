"""Order domain logic (extend when order APIs are added)."""

from app.events.order_events import emit_order_created


async def publish_order_created_event(order_id: str, customer_id: str) -> None:
    """Enqueue downstream workflows after an order is persisted."""
    emit_order_created(order_id, customer_id)
