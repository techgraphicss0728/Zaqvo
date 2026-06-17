"""Order lifecycle events → Celery fan-out."""

from app.workers.orders import order_created_fanout


def emit_order_created(order_id: str, customer_id: str) -> None:
    order_created_fanout.delay(order_id, customer_id)
