# setup.ps1 — create venv and install requirements (PowerShell)
# Run in project root: .\setup.ps1

# Create venv if not present
if (-not (Test-Path -Path "venv")) {
    python -m venv venv
}

# Activate the venv in this script
. .\venv\Scripts\Activate.ps1

# Upgrade pip and install requirements
python -m pip install --upgrade pip
pip install -r requirements.txt

Write-Host "Setup complete. To run the app, activate the venv with:`n.\venv\Scripts\Activate.ps1` and then run `python app.py`" -ForegroundColor Green
