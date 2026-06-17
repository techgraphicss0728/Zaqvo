"""
Zaqvo API — FastAPI application entry.
Stateless, ready for horizontal scaling behind a load balancer.
"""
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded

from app.api.v1.router import api_router
from app.core.config import settings
from app.core.errors import register_exception_handlers
from app.core.logging import setup_logging
from app.core.limiter import limiter
from app.core.auth_middleware import AuthMiddleware
from app.core.middleware import RequestLoggingMiddleware
from app.core.cache import close_redis, connect_redis
from app.db.mongodb import close_mongo, connect_mongo
from app.db.seed import seed_dashboard_defaults

setup_logging()


@asynccontextmanager
async def lifespan(app: FastAPI):
    await connect_mongo()
    await connect_redis()
    await seed_dashboard_defaults()
    yield
    await close_redis()
    await close_mongo()


def create_application() -> FastAPI:
    allowed_origins = [
        origin.strip() for origin in settings.CORS_ORIGINS.split(",") if origin.strip()
    ]

    app = FastAPI(
        title=settings.PROJECT_NAME,
        openapi_url=f"{settings.API_V1_PREFIX}/openapi.json",
        docs_url="/docs",
        redoc_url="/redoc",
        lifespan=lifespan,
    )

    app.add_middleware(
        CORSMiddleware,
        allow_origins=allowed_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    app.add_middleware(RequestLoggingMiddleware)
    app.add_middleware(AuthMiddleware)

    app.state.limiter = limiter
    app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
    register_exception_handlers(app)

    app.include_router(api_router, prefix=settings.API_V1_PREFIX)

    @app.get("/health")
    async def health():
        return {"status": "ok"}

    @app.get("/ready")
    async def ready():
        from fastapi.responses import JSONResponse
        from app.db.mongodb import is_ready
        ok = await is_ready()
        if not ok:
            return JSONResponse(content={"ready": False}, status_code=503)
        return {"ready": True}

    return app


app = create_application()
