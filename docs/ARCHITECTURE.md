# Zaqvo — Architecture & Software Design

Scalable multi-app platform designed to handle **1M+ requests** with horizontal scaling, CI/CD, and clear separation of concerns.

---

## 1. High-Level Architecture

```
                                    ┌─────────────────────────────────────────────────────────┐
                                    │                    Load Balancer                         │
                                    │              (Nginx / AWS ALB / Cloudflare)               │
                                    └─────────────────────────┬───────────────────────────────┘
                                                              │
         ┌──────────────────┬──────────────────┬──────────────┼──────────────┬──────────────────┐
         │                  │                  │              │              │                  │
         ▼                  ▼                  ▼              ▼              ▼                  ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────────┐
│   zaqvo-web     │ │ zaqvo-dashboard  │ │  API    │ │  API        │ │  API        │ │  (more API      │
│   (Website)     │ │ (React/Vite)     │ │ Node 1  │ │ Node 2      │ │ Node N      │ │  instances)     │
└─────────────────┘ └─────────────────┘ └────┬────┘ └──────┬──────┘ └──────┬──────┘ └────────┬────────┘
         │                  │                 │             │               │                 │
         │                  │                 └─────────────┼───────────────┴─────────────────┘
         │                  │                               │
         │                  │                    ┌──────────▼──────────┐
         │                  │                    │   zaqvo-backend     │
         │                  │                    │   (FastAPI)         │
         │                  │                    │   Stateless,        │
         │                  │                    │   horizontally      │
         │                  │                    │   scalable          │
         │                  │                    └──────────┬──────────┘
         │                  │                               │
    ┌────┴────┐        ┌────┴────┐              ┌───────────┼───────────┐
    │         │        │         │              │           │           │
    ▼         ▼        ▼         ▼              ▼           ▼           ▼
┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐   ┌─────────┐ ┌─────────┐ ┌─────────┐
│Customer│ │Delivery│ │Dashboard│ │ Web   │   │ MongoDB │ │  Redis  │ │ Celery  │
│  App   │ │  App   │ │  (Web)  │ │(static)│   │(Primary │ │ (Cache/ │ │ Workers │
│Flutter │ │Flutter │ │         │ │        │   │+ Replica)│ │ Session)│ │(Scalable)│
└───────┘ └───────┘ └───────┘ └───────┘   └─────────┘ └─────────┘ └─────────┘
```

---

## 2. Components Overview

| Component           | Tech Stack                    | Role                                      |
|--------------------|-------------------------------|-------------------------------------------|
| **zaqvo-web**      | Existing (React/Vite)         | Marketing/landing website                 |
| **zaqvo-backend**  | Python, FastAPI, MongoDB      | REST/API, auth, business logic            |
| **zaqvo-customer-app** | Flutter                   | Customer-facing mobile (Android/iOS)      |
| **zaqvo-delivery-app** | Flutter                   | Delivery partner mobile (Android/iOS)     |
| **zaqvo-dashboard**| React, Vite, TS, Tailwind, shadcn | Reports, analytics, admin              |
| **Background jobs**| Celery + Redis (broker)       | Cron, async tasks, heavy processing       |
| **Database**       | MongoDB                       | Primary data store                        |
| **Cache/Session**  | Redis                         | Caching, rate limiting, Celery broker     |

---

## 3. Scalability Strategy (1M Requests)

### 3.1 Horizontal Scaling

- **API:** Run multiple FastAPI instances behind a load balancer. No in-memory session state; use Redis for sessions if needed.
- **Celery:** Scale worker count independently for background jobs.
- **MongoDB:** Use replica set + read preference for read scaling; sharding when data grows.
- **Redis:** Redis Cluster or managed Redis for high availability.

### 3.2 Performance Practices

- **Caching:** Redis for hot data (e.g. user session, frequently read entities).
- **Rate limiting:** Per-IP and per-user limits to protect backend (e.g. slowapi or custom middleware).
- **Connection pooling:** MongoDB and Redis connection pools; reuse in async FastAPI.
- **Async I/O:** FastAPI async endpoints and async MongoDB driver (motor) for non-blocking I/O.
- **CDN:** Static assets and (if applicable) API caching at edge for dashboard/web.
- **Pagination & lean queries:** Cursor/offset pagination; project only needed fields in MongoDB.

### 3.3 Resilience

- Health checks: `/health` and `/ready` for load balancer and orchestrator.
- Graceful shutdown: drain connections, finish in-flight requests.
- Circuit breakers for external services (e.g. payment, notifications).
- Structured logging and metrics (e.g. Prometheus) for observability.

---

## 4. Software Design Principles

- **Stateless API:** No server-side session storage in app; auth via JWT or token in Redis.
- **API-first:** Single backend serves customer app, delivery app, and dashboard; versioned APIs (e.g. `/api/v1/`).
- **Domain-oriented structure:** Backend organized by domain (auth, orders, delivery, analytics) for clarity and scaling.
- **Background processing:** Long or heavy work (emails, reports, cron) in Celery, not in request path.
- **Configuration via env:** All environments (dev/staging/prod) driven by environment variables; no secrets in code.

---

## 5. Security

- **Auth:** JWT (or short-lived access + refresh tokens) with role-based access (customer, delivery, admin).
- **HTTPS only** in production; secure cookies for dashboard if needed.
- **Input validation:** Pydantic on API; sanitize and validate all inputs.
- **Secrets:** Env vars or secret manager (e.g. AWS Secrets Manager); never in repo.
- **CORS:** Restrict origins per app (customer, delivery, dashboard, web).

---

## 6. CI/CD Pipeline

- **Build:** Run tests and lint on every push/PR.
- **Deploy:** On merge to `main` (or release branch): build Docker images, push to registry, deploy to production (e.g. K8s, ECS, or VM fleet).
- **Migrations:** Run DB migrations/scripts as part of deploy or a separate job; backward-compatible changes preferred.
- **Rollback:** Tagged images and repeatable deploy process for quick rollback.

---

## 7. Repository Layout (Monorepo)

```
Zaqvo/
├── docs/                    # Architecture, ADRs, runbooks
├── zaqvo-web/               # Existing marketing website
├── zaqvo-backend/           # FastAPI + Celery
├── zaqvo-customer-app/      # Flutter customer app
├── zaqvo-delivery-app/      # Flutter delivery app
├── zaqvo-dashboard/         # React + Vite + Tailwind + shadcn
├── .github/workflows/       # CI/CD (build, test, deploy)
├── docker-compose.yml       # Local/dev stack
├── docker-compose.prod.yml  # Production-like stack (optional)
└── README.md
```

---

## 8. API Design (Backend)

- **Base path:** `https://api.zaqvo.com/api/v1` (or your domain).
- **Auth:** `Authorization: Bearer <access_token>`.
- **Responses:** JSON; consistent envelope if needed, e.g. `{ "data": ..., "meta": { "page", "limit" } }`.
- **Errors:** HTTP status + JSON body with `code` and `message`; use 429 for rate limit.
- **Versioning:** URL path `/api/v1/`; maintain v1 while introducing v2 when needed.

---

## 9. Database (MongoDB) Guidelines

- **Collections:** Design around access patterns; avoid unbounded arrays in documents.
- **Indexes:** Index all query and sort fields; compound indexes for common filters.
- **Idempotency:** Use unique indexes or idempotency keys for critical writes (e.g. payments, order creation).
- **Replica set:** Minimum 3 nodes for production; read from secondaries for reporting/analytics where acceptable.

---

## 10. Celery Usage

- **Broker:** Redis (recommended for performance and simplicity).
- **Tasks:** Idempotent where possible; use task result backend (e.g. Redis) for status.
- **Scheduling:** Celery Beat for cron-like jobs (e.g. daily reports, cleanup).
- **Scaling:** Add more workers under same app name; monitor queue depth and latency.

This document should be updated when major architectural decisions change (e.g. adding a message queue, moving to Kubernetes).
