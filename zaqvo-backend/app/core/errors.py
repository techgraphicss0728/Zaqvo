"""Centralized API error handling with consistent envelopes."""
from __future__ import annotations

from typing import Any

import structlog
from fastapi import FastAPI, HTTPException, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from starlette import status

logger = structlog.get_logger()


def _request_id(request: Request) -> str | None:
    rid = getattr(request.state, "request_id", None)
    return str(rid) if rid else None


def _error_response(
    request: Request,
    *,
    code: str,
    message: str,
    status_code: int,
    details: Any = None,
) -> JSONResponse:
    payload: dict[str, Any] = {
        "error": {
            "code": code,
            "message": message,
        },
        "request_id": _request_id(request),
    }
    if details is not None:
        payload["error"]["details"] = details
    return JSONResponse(status_code=status_code, content=payload)


def register_exception_handlers(app: FastAPI) -> None:
    @app.exception_handler(RequestValidationError)
    async def _validation_error_handler(request: Request, exc: RequestValidationError):
        return _error_response(
            request,
            code="validation_error",
            message="Invalid request",
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            details=exc.errors(),
        )

    @app.exception_handler(HTTPException)
    async def _http_exception_handler(request: Request, exc: HTTPException):
        detail = exc.detail if isinstance(exc.detail, str) else "Request failed"
        details = None if isinstance(exc.detail, str) else exc.detail
        return _error_response(
            request,
            code="http_error",
            message=detail,
            status_code=exc.status_code,
            details=details,
        )

    @app.exception_handler(Exception)
    async def _unhandled_exception_handler(request: Request, exc: Exception):
        logger.exception(
            "unhandled_exception",
            request_id=_request_id(request),
            method=request.method,
            path=request.url.path,
        )
        return _error_response(
            request,
            code="internal_server_error",
            message="Internal server error",
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )
