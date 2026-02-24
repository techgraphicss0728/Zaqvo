# Run Zaqvo Backend Without Docker

Use this when developing locally. Use Docker only for building and pushing images to ECR.

## 1. Prerequisites

- **Python 3.11+** — [python.org](https://www.python.org/downloads/)
- **MongoDB** — running on `localhost:27017` (install locally or run only MongoDB in Docker)
- **Redis** — running on `localhost:6379` (install locally or run only Redis in Docker)

## 2. One-time setup

```powershell
cd C:\Users\ennam\Zaqvo\zaqvo-backend

# Create virtual environment
python -m venv .venv

# Activate (Windows PowerShell)
.\.venv\Scripts\Activate.ps1

# Install dependencies
pip install -r requirements.txt

# Create .env from example and edit if needed
copy .env.example .env
```

Edit `.env` if your MongoDB or Redis are not on localhost.

## 3. Run the API

From the project root with `.venv` activated:

```powershell
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

- API: **http://localhost:8000**
- Docs: **http://localhost:8000/docs**
- Health: **http://localhost:8000/health**

## 4. (Optional) Run Celery

If your app uses background tasks, in a **second terminal** (with `.venv` activated):

```powershell
# Worker
celery -A app.celery_app worker -l info

# Beat (scheduler) — third terminal if you use scheduled tasks
celery -A app.celery_app beat -l info
```

## Quick run script (Windows)

With venv and `.env` already set up:

```powershell
.\.venv\Scripts\Activate.ps1; uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Or use the provided script:

```powershell
.\run.ps1
```
