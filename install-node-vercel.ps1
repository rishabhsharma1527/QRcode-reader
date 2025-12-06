<#
install-node-vercel.ps1

Helper script to install Node.js (LTS) via winget when available, verify npm, install the Vercel CLI globally,
and ensure npm's global bin folder is on the user PATH.

Run in an elevated PowerShell if winget fails due to permissions.
Usage: Open PowerShell in this project folder and run:
    .\install-node-vercel.ps1
#>

function Write-Info { param($m) Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Write-Ok   { param($m) Write-Host "[ OK ] $m" -ForegroundColor Green }
function Write-Err  { param($m) Write-Host "[ERR ] $m" -ForegroundColor Red }

Write-Info "Starting Node + Vercel installer helper"

# 1) Check winget
$wingetCmd = Get-Command winget -ErrorAction SilentlyContinue
if ($wingetCmd) {
    Write-Info "winget detected: $($wingetCmd.Path)"
    Write-Info "Attempting to install Node.js LTS via winget (this may prompt / require elevation)"
    try {
        winget install --id OpenJS.NodeJS.LTS -e --accept-package-agreements --accept-source-agreements
        Write-Ok "winget install completed (check output above)."
    } catch {
        Write-Err "winget install failed: $($_.Exception.Message)"
        Write-Info "You can install Node.js manually from https://nodejs.org/en/download/"
    }
} else {
    Write-Info "winget not found. Please download and run the Node.js LTS installer from:"
    Write-Host "  https://nodejs.org/en/download/" -ForegroundColor Yellow
}

Write-Info "Waiting a few seconds for installer to settle..."
Start-Sleep -Seconds 3

# 2) Verify node and npm are available
$node = (Get-Command node -ErrorAction SilentlyContinue)
$npm = (Get-Command npm -ErrorAction SilentlyContinue)
if (-not $node -or -not $npm) {
    Write-Err "Node or npm not found in PATH. If you just installed Node, please close and re-open PowerShell and re-run this script."
    Write-Host "Press Enter to continue (attempt to reinstall Vercel if npm becomes available), or Ctrl+C to cancel." -NoNewline
    [Console]::ReadLine() | Out-Null
}

# Re-check
$nodeV = & node -v 2>$null
$npmV  = & npm -v 2>$null
if ($nodeV) { Write-Ok "node version: $nodeV" } else { Write-Err "node not found" }
if ($npmV)  { Write-Ok "npm version: $npmV" } else  { Write-Err "npm not found" }

if (-not $npmV) {
    Write-Err "npm is required to install the Vercel CLI. Install Node.js (which includes npm), then re-run this script."
    exit 1
}

# 3) Install Vercel CLI globally
Write-Info "Installing Vercel CLI globally via npm..."
try {
    npm install --location=global vercel
    Write-Ok "npm install finished"
} catch {
    Write-Err "npm install failed: $($_.Exception.Message)"
    Write-Host "Try running PowerShell as Administrator and re-run: npm install --location=global vercel" -ForegroundColor Yellow
}

# 4) Verify vercel binary
$vercel = (Get-Command vercel -ErrorAction SilentlyContinue)
if ($vercel) {
    $verVersion = & vercel --version 2>$null
    Write-Ok "vercel is installed: $verVersion"
    exit 0
}

Write-Info "vercel command not found. Attempting to add npm global bin to user PATH."
$npmBin = (& npm bin -g) -join ''
Write-Info "npm global bin appears to be: $npmBin"

if ($npmBin -and -not ($env:Path -split ';' | Where-Object { $_ -eq $npmBin })) {
    Write-Info "Adding npm global bin to user PATH"
    $newPath = "$env:Path;$npmBin"
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Ok "Added $npmBin to user PATH. You must close and re-open PowerShell for the change to apply."
} else {
    Write-Info "npm global bin is already on PATH or could not be determined."
}

Write-Info "Final check: you may need to open a NEW PowerShell window. After that, run: vercel --version"
Write-Host "If vercel still isn't found, try: npm install --location=global vercel (in an elevated PowerShell)" -ForegroundColor Yellow

Write-Info "Done."
