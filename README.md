# Friendly QR Maker & Scanner

This is a small Flask app that can generate and scan QR codes.

Quick setup (Windows PowerShell)

1. Create a virtual environment and activate it

```powershell
python -m venv venv
.\venv\Scripts\Activate.ps1
```

2. Install dependencies

```powershell
pip install --upgrade pip
pip install -r requirements.txt
```

3. Run the app

```powershell
python app.py
```

The app will be available at http://127.0.0.1:5000

Helper scripts

- `setup.ps1` — creates the venv and installs requirements.
- `run.ps1` — activates the venv and runs `python app.py`.

Notes

- If PowerShell refuses to run scripts, you can set the execution policy for your user session:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

- The UI already includes a camera-based scanner (uses `jsQR` from CDN) and a simple `/generate` endpoint that returns a PNG for download.

If you want, I can also:
- Pin dependency versions in `requirements.txt`.
- Add a tiny test that requests `/` and checks for 200.
- Start the server here to verify it runs.

Tell me which of those you'd like next.