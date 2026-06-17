"""Backward-compatible task imports (implementations in ``app.workers``)."""


def __getattr__(name: str):
    if name == "daily_cleanup":
        from app.workers.scheduled import daily_cleanup as task

        return task
    if name == "delete_s3_object":
        from app.workers.storage import delete_s3_object as task

        return task
    raise AttributeError(name)


__all__ = ["daily_cleanup", "delete_s3_object"]
