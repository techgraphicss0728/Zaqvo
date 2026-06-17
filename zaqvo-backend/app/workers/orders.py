"""Order lifecycle background steps (fan-out from domain events)."""
import structlog

from app.celery_app import celery_app

logger = structlog.get_logger(__name__)


@celery_app.task(name="app.workers.orders.notify_order_created")
def notify_order_created(order_id: str):
    logger.info("notify_order_created", order_id=order_id)
    return {"order_id": order_id, "step": "notify"}


@celery_app.task(name="app.workers.orders.assign_delivery")
def assign_delivery_worker(order_id: str):
    logger.info("assign_delivery_worker", order_id=order_id)
    return {"order_id": order_id, "step": "assign_delivery"}


@celery_app.task(name="app.workers.orders.record_analytics")
def record_order_analytics(order_id: str):
    logger.info("record_order_analytics", order_id=order_id)
    return {"order_id": order_id, "step": "analytics"}


@celery_app.task(name="app.workers.orders.order_created_fanout")
def order_created_fanout(order_id: str, customer_id: str):
    notify_order_created.delay(order_id)
    assign_delivery_worker.delay(order_id)
    record_order_analytics.delay(order_id)
    return {"order_id": order_id, "customer_id": customer_id, "fanout": True}
