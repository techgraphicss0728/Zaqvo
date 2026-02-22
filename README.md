# Zaqvo

Scalable multi-app platform (1M+ requests): backend, customer app, delivery app, dashboard.

## Repository structure

| Folder | Stack | Purpose |
|--------|--------|--------|
| **zaqvo-web** | React, Vite | Marketing/website (existing) |
| **zaqvo-backend** | Python, FastAPI, MongoDB, Celery, Redis | API, auth, background jobs |
| **zaqvo-customer-app** | Flutter | Customer mobile (Android/iOS) |
| **zaqvo-delivery-app** | Flutter | Delivery partner mobile (Android/iOS) |
| **zaqvo-dashboard** | React, Vite, TypeScript, Tailwind, shadcn | Reports & analytics (admin) |

## Architecture & scaling

- **Architecture:** [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — high-level design, horizontal scaling, CI/CD, security.
- **Backend:** Stateless FastAPI; scale by running more API instances behind a load balancer.
- **Celery:** Redis as broker; scale by adding more workers.
- **Database:** MongoDB (replica set in production); use indexes and lean queries.
- **CI/CD:** GitHub Actions — `CI` on push/PR (lint, test, build); `Deploy` on push to `main` (build & push Docker images).

## Quick start (local)

### Backend + DB + workers

```bash
cd zaqvo-backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
# Start MongoDB & Redis (e.g. Docker), then:
uvicorn app.main:app --reload --port 8000
# In another terminal: celery -A app.celery_app worker -l info
# Optional: celery -A app.celery_app beat -l info
```

### Full stack with Docker

```bash
docker-compose up -d
# API: http://localhost:8000
# Dashboard: http://localhost:5174
# MongoDB: 27017, Redis: 6379
```

### Dashboard

```bash
cd zaqvo-dashboard
npm install
cp .env.example .env
npm run dev
```

### Flutter apps

```bash
cd zaqvo-customer-app   # or zaqvo-delivery-app
flutter pub get
# Set API_BASE_URL in .env
flutter run
```

## Production deployment

1. Set secrets and env (e.g. `SECRET_KEY`, `MONGODB_URI`, `REDIS_URL`, `CORS_ORIGINS`).
2. Use a load balancer in front of multiple API replicas.
3. Run Celery workers (and Beat once) against the same Redis broker.
4. Use the Deploy workflow or your own pipeline to build images and deploy (e.g. ECS, Kubernetes, Cloud Run).

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for details.
