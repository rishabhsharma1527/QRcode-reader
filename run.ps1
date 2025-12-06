# run.ps1 — activate venv and run app (PowerShell)
# Run in project root: .\run.ps1

if (-not (Test-Path -Path "venv")) {
    Write-Host "Virtual environment 'venv' not found. Run .\setup.ps1 first." -ForegroundColor Yellow
    exit 1
}

# Activate venv in this script
. .\venv\Scripts\Activate.ps1

# Run the app
python app.py
