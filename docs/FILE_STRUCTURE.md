# Zaqvo — File structure reference

## Monorepo root

```
Zaqvo/
├── docs/                    # Architecture, file structure
├── .github/workflows/       # CI (ci.yml), CD (deploy.yml)
├── zaqvo-web/               # Existing marketing website
├── zaqvo-backend/           # FastAPI + Celery
├── zaqvo-customer-app/      # Flutter customer app
├── zaqvo-delivery-app/      # Flutter delivery app
├── zaqvo-dashboard/         # React dashboard (reports/analytics)
├── docker-compose.yml       # Local/dev full stack
└── README.md
```

---

## zaqvo-backend (Python, FastAPI, Celery, MongoDB)

```
zaqvo-backend/
├── app/
│   ├── __init__.py
│   ├── main.py              # FastAPI app, lifespan, /health, /ready
│   ├── celery_app.py        # Celery + Beat schedule
│   ├── api/
│   │   ├── deps.py          # get_current_user, get_current_user_optional
│   │   └── v1/
│   │       ├── router.py     # Aggregates v1 routes
│   │       └── endpoints/    # auth, users, health
│   ├── core/
│   │   ├── config.py        # Settings from env
│   │   ├── security.py     # JWT, password hash
│   │   ├── logging.py
│   │   ├── limiter.py      # Rate limiting (slowapi)
│   │   └── middleware.py   # Request logging
│   ├── db/
│   │   └── mongodb.py       # Motor async client, connect/close
│   ├── models/              # Pydantic / Beanie (user, etc.)
│   ├── services/            # Business logic (user_service, etc.)
│   └── tasks/               # Celery tasks (scheduled, ad-hoc)
├── tests/
├── requirements.txt
├── .env.example
├── pytest.ini
├── Dockerfile
└── README.md
```

---

## zaqvo-customer-app (Flutter)

```
zaqvo-customer-app/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── config/          # app_config.dart
│   │   ├── theme/           # app_theme.dart
│   │   ├── router/          # app_router.dart (go_router)
│   │   └── api/             # api_client.dart (Dio)
│   ├── features/
│   │   ├── auth/            # login_page, ...
│   │   └── home/            # home_page, ...
│   └── shared/
│       └── widgets/         # loading_indicator, ...
├── pubspec.yaml
├── .env.example
├── analysis_options.yaml
└── README.md
```

---

## zaqvo-delivery-app (Flutter)

Same structure as customer app; different branding and features (delivery-specific screens).

```
zaqvo-delivery-app/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/                # config, theme, router, api
│   ├── features/            # auth, home, (deliveries, etc.)
│   └── shared/
├── pubspec.yaml
├── .env.example
└── ...
```

---

## zaqvo-dashboard (React, Vite, TypeScript, Tailwind, shadcn)

```
zaqvo-dashboard/
├── src/
│   ├── main.tsx
│   ├── App.tsx              # Routes
│   ├── index.css            # Tailwind + CSS variables
│   ├── lib/
│   │   ├── utils.ts         # cn()
│   │   └── api.ts          # fetch wrapper, auth header
│   ├── components/
│   │   ├── ui/              # button, card (shadcn-style)
│   │   └── layout/          # DashboardLayout, Sidebar, Header
│   └── pages/               # DashboardPage, ReportsPage, AnalyticsPage, LoginPage
├── index.html
├── package.json
├── vite.config.ts
├── tailwind.config.js
├── tsconfig.json
├── .env.example
├── Dockerfile               # Multi-stage: node build + nginx serve
├── nginx.conf
└── README.md
```

---

## Scaling (file / config)

- **Backend:** Add more replicas in `docker-compose.yml` or in your orchestrator (K8s/ECS). No app code change.
- **Celery:** Run more worker processes or more containers with the same `celery worker` command.
- **CI/CD:** `.github/workflows/ci.yml` (lint + test); `.github/workflows/deploy.yml` (build and push images on `main`).
