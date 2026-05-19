#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------------------
# Deploy Kilo CLI on Fly.io with Azure Key Vault secret injection
# ------------------------------------------------------------------------------

KEY_VAULT_NAME="${KEY_VAULT_NAME:-}"
SECRET_NAME="${SECRET_NAME:-kilo-api-key}"
FLY_APP_NAME="${FLY_APP_NAME:-kilo-remote}"
FLY_REGION="${FLY_REGION:-lhr}"
VOLUME_SIZE="${VOLUME_SIZE:-10}"
VOLUME_NAME="${VOLUME_NAME:-kilo_data}"

# --- validation ----------------------------------------------------------------

if ! command -v az &>/dev/null; then
    echo "❌ Azure CLI (az) is not installed. Install: https://aka.ms/installazurecli"
    exit 1
fi

if ! command -v flyctl &>/dev/null; then
    echo "❌ flyctl is not installed. Install: https://fly.io/docs/hands-on/install-flyctl/"
    exit 1
fi

if [ -z "$KEY_VAULT_NAME" ]; then
    echo "❌ KEY_VAULT_NAME is not set. Example:"
    echo "   KEY_VAULT_NAME=my-kilo-vault ./deploy.sh"
    exit 1
fi

# Ensure we are signed in to Azure and Fly
az account show &>/dev/null || {
    echo "🔐 Logging in to Azure..."
    az login
}

flyctl auth whoami &>/dev/null || {
    echo "🔐 Logging in to Fly.io..."
    flyctl auth login
}

# --- fetch secret from Azure Key Vault -----------------------------------------

echo "🔑 Fetching Kilo API key from Azure Key Vault..."
API_KEY=$(az keyvault secret show \
    --name "$SECRET_NAME" \
    --vault-name "$KEY_VAULT_NAME" \
    --query value -o tsv)

if [ -z "$API_KEY" ]; then
    echo "❌ Failed to retrieve secret '$SECRET_NAME' from vault '$KEY_VAULT_NAME'"
    exit 1
fi

# --- push secrets to Fly.io ----------------------------------------------------

echo "🔒 Injecting KILO_API_KEY into Fly.io app '$FLY_APP_NAME'..."
printf '%s' "$API_KEY" | flyctl secrets set KILO_API_KEY=- --app "$FLY_APP_NAME"

# Set a random TTYD_PASSWORD if not already present
if ! flyctl secrets list --app "$FLY_APP_NAME" | grep -q "TTYD_PASSWORD"; then
    RAND_PASS=$(openssl rand -base64 24 2>/dev/null || head -c 32 /dev/urandom | base64)
    echo "🔒 Setting random TTYD_PASSWORD for browser terminal auth..."
    printf '%s' "$RAND_PASS" | flyctl secrets set TTYD_PASSWORD=- --app "$FLY_APP_NAME"
    echo "   (To see it later: flyctl secrets list --app $FLY_APP_NAME)"
else
    echo "🔒 TTYD_PASSWORD already set."
fi

# --- provision volume (idempotent) ---------------------------------------------

if ! flyctl volumes list --app "$FLY_APP_NAME" | grep -q "$VOLUME_NAME"; then
    echo "💾 Creating persistent volume '$VOLUME_NAME' (${VOLUME_SIZE}GB) in $FLY_REGION..."
    flyctl volumes create "$VOLUME_NAME" \
        --region "$FLY_REGION" \
        --size "$VOLUME_SIZE" \
        --app "$FLY_APP_NAME" \
        --yes
else
    echo "💾 Volume '$VOLUME_NAME' already exists."
fi

# --- deploy ----------------------------------------------------------------------

echo "🚀 Deploying to Fly.io..."
flyctl deploy --app "$FLY_APP_NAME"

echo ""
echo "✅ Done!"
echo ""
echo "   SSH (from terminal):"
echo "   ssh -p 2222 root://${FLY_APP_NAME}.fly.dev"
echo ""
echo "   Browser Terminal (real bash in browser):"
echo "   https://${FLY_APP_NAME}.fly.dev"
echo "   (Login: root / TTYD_PASSWORD from flyctl secrets list)"
echo ""
echo "   After connecting, run:"
echo "   kilo --version"
echo "   kilo run \"explain what this codebase does\""
echo ""
