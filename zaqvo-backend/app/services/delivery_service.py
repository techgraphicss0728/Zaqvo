"""Delivery assignment — enqueue background work for drivers."""

from app.workers.orders import assign_delivery_worker


def enqueue_delivery_assignment(order_id: str) -> None:
    assign_delivery_worker.delay(order_id)
