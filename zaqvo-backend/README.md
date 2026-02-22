# Zaqvo Backend

FastAPI backend with MongoDB and Celery. Stateless, horizontally scalable.

## Setup

```bash
python -m venv .venv
.venv\Scripts\activate   # Windows
pip install -r requirements.txt
cp .env.example .env     # Edit with your values
```

## Run

- API: `uvicorn app.main:app --reload --host 0.0.0.0 --port 8000`
- Celery worker: `celery -A app.celery_app worker -l info`
- Celery beat: `celery -A app.celery_app beat -l info`

## Docker

```bash
docker-compose -f ../docker-compose.yml up -d
```

## Health

- `GET /health` — liveness
- `GET /ready` — readiness (DB + Redis)
