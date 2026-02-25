#Requires -Version 7
# ⚡ KiloCode CLI — Windows Installer (PowerShell 7)
# Run as Administrator: .\install_windows.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Log  { Write-Host "[INFO] $args" -ForegroundColor Cyan }
function Ok   { Write-Host "[ OK ] $args" -ForegroundColor Green }
function Warn { Write-Host "[WARN] $args" -ForegroundColor Yellow }
function Err  { Write-Host "[ERR ] $args" -ForegroundColor Red; exit 1 }

Write-Host ""
Write-Host "⚡ KiloCode CLI — Windows Installer" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# ── Check Admin ──────────────────────────────────────────────
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Err "Please run PowerShell 7 as Administrator"
}

# ── 1. winget check ──────────────────────────────────────────
Log "Checking winget..."
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  Err "winget not found. Please update the App Installer from Microsoft Store."
}
Ok "winget available"

# ── 2. Node.js ───────────────────────────────────────────────
Log "Checking Node.js..."
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
  Log "Installing Node.js 20 LTS..."
  winget install --id OpenJS.NodeJS.LTS -e --accept-source-agreements --accept-package-agreements
  # Refresh PATH
  $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
}
$nodeVer = node --version
Ok "Node.js $nodeVer"

# ── 3. Docker Desktop ────────────────────────────────────────
Log "Checking Docker..."
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  Log "Installing Docker Desktop..."
  winget install --id Docker.DockerDesktop -e --accept-source-agreements --accept-package-agreements
  Warn "Please start Docker Desktop and complete setup, then press ENTER to continue."
  Read-Host
}
Ok "Docker $(docker --version)"

# ── 4. Ollama ────────────────────────────────────────────────
Log "Checking Ollama..."
if (-not (Get-Command ollama -ErrorAction SilentlyContinue)) {
  Log "Installing Ollama for Windows..."
  winget install --id Ollama.Ollama -e --accept-source-agreements --accept-package-agreements
  Start-Sleep -Seconds 5
}

Log "Pulling nomic-embed-text (274 MB)..."
$models = (ollama list 2>&1) | Out-String
if ($models -notlike "*nomic-embed-text*") {
  ollama pull nomic-embed-text
}
Ok "Ollama + nomic-embed-text ready"

# ── 5. Qdrant ────────────────────────────────────────────────
Log "Starting Qdrant..."
$running = (docker ps 2>&1) | Out-String
if ($running -notlike "*qdrant*") {
  docker run -d --name qdrant --restart unless-stopped `
    -p 6333:6333 `
    -v qdrant_storage:/qdrant/storage `
    qdrant/qdrant:latest
  Start-Sleep -Seconds 5
}

Log "Creating kilocode_docs collection..."
try {
  Invoke-RestMethod -Method PUT `
    -Uri http://localhost:6333/collections/kilocode_docs `
    -ContentType "application/json" `
    -Body '{"vectors":{"size":4096,"distance":"Cosine"}}' | Out-Null
} catch {
  Warn "Collection may already exist — continuing"
}
Ok "Qdrant running on :6333"

# ── 6. KiloCode CLI ──────────────────────────────────────────
Log "Installing KiloCode CLI..."
npm install -g kilocode

# Add npm global bin to PATH if not present
$npmPrefix = (npm config get prefix)
$userPath = [Environment]::GetEnvironmentVariable("PATH","User")
if ($userPath -notlike "*$npmPrefix*") {
  [Environment]::SetEnvironmentVariable("PATH", "$userPath;$npmPrefix", "User")
  $env:PATH += ";$npmPrefix"
}

Log "Configuring KiloCode..."
kilocode config set embeddings.provider ollama
kilocode config set embeddings.model nomic-embed-text
kilocode config set embeddings.dimensions 4096
kilocode config set vectordb.provider qdrant
kilocode config set vectordb.host http://localhost:6333
Ok "KiloCode configured"

# ── 7. Verify ────────────────────────────────────────────────
Write-Host ""
Write-Host "🔍 Running health check..." -ForegroundColor Cyan
try { kilocode doctor } catch { Warn "Some checks may have warnings — see output above" }

Write-Host ""
Write-Host "✅ Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "   Try it:" -ForegroundColor White
Write-Host "   cd C:\your-project" -ForegroundColor Gray
Write-Host "   kilocode index ." -ForegroundColor Gray
Write-Host "   kilocode ask 'what does this code do?'" -ForegroundColor Gray
Write-Host ""
