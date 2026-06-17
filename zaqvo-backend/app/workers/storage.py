"""Background tasks for storage object cleanup."""
from app.celery_app import celery_app
from app.services.storage_service import storage_service


@celery_app.task(
    name="app.tasks.storage.delete_s3_object",
    autoretry_for=(Exception,),
    retry_kwargs={"max_retries": 5, "countdown": 10},
)
def delete_s3_object(key: str):
    storage_service.delete_object(key)
    return {"ok": True, "key": key}
