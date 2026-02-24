# Run Zaqvo backend locally (no Docker). Ensure .venv exists and .env is configured.
Set-Location $PSScriptRoot
if (-not (Test-Path ".venv\Scripts\Activate.ps1")) {
    Write-Host "Creating venv..." -ForegroundColor Yellow
    python -m venv .venv
}
& .\.venv\Scripts\Activate.ps1
if (-not (Test-Path ".venv\Lib\site-packages\uvicorn")) {
    Write-Host "Installing dependencies (pip install -r requirements.txt)..." -ForegroundColor Yellow
    pip install -r requirements.txt
    if (-not (Test-Path ".venv\Lib\site-packages\uvicorn")) {
        Write-Host "Install failed. This project needs Python 3.11 or 3.12. Try: py -3.12 -m venv .venv" -ForegroundColor Red
        exit 1
    }
}
if (-not (Test-Path ".env")) {
    Write-Host "Copying .env.example to .env. Edit .env if needed." -ForegroundColor Yellow
    Copy-Item .env.example .env
}
Write-Host "Starting API at http://localhost:8000 (docs: http://localhost:8000/docs)" -ForegroundColor Green
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000


# deactivate
# Remove-Item -Recurse -Force .venv
# py -3.11 -m venv .venv
# .\.venv\Scripts\Activate.ps1
# pip install -r requirements.txt
# uvicorn app.main:app --reload