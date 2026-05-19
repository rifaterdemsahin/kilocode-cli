#!/usr/bin/env bash
set -euo pipefail

# Export terminal environment for TUI apps (kilo, etc.)
export TERM=xterm-256color
export COLUMNS=${COLUMNS:-80}
export LINES=${LINES:-24}

# Ensure SSH host keys exist (regenerated on first boot if missing)
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -A
fi

# Enable root login with password for SSH (single-tenant VM)
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Lock down authorized_keys permissions if present
if [ -f /root/.ssh/authorized_keys ]; then
    chmod 600 /root/.ssh/authorized_keys
    chown root:root /root/.ssh/authorized_keys
fi

# If KILO_API_KEY is provided as a Fly secret, log confirmation
if [ -n "${KILO_API_KEY:-}" ]; then
    echo "✓ KILO_API_KEY is set (length: ${#KILO_API_KEY})"
else
    echo "⚠ KILO_API_KEY is not set. Run: flyctl secrets set KILO_API_KEY=<key>"
fi

# Keep projects mount owned by root (matches container user)
if [ -d /root/projects ]; then
    chown root:root /root/projects || true
fi

# Start SSH daemon in the background
echo "Starting SSH daemon on port 2222..."
/usr/sbin/sshd -D -p 2222 &

# Start ttyd (real browser terminal) on port 7681
# If TTYD_PASSWORD is set, require authentication
echo "Starting ttyd (browser terminal) on port 7681..."
if [ -n "${TTYD_PASSWORD:-}" ]; then
    exec /usr/local/bin/ttyd \
        --port 7681 \
        --credential "root:${TTYD_PASSWORD}" \
        --writable \
        bash -c 'export TERM=xterm-256color COLUMNS=80 LINES=24; exec bash'
else
    echo "⚠ TTYD_PASSWORD not set — browser terminal will be open (no auth)."
    echo "  Set it with: flyctl secrets set TTYD_PASSWORD=<strong-password>"
    exec /usr/local/bin/ttyd \
        --port 7681 \
        --writable \
        bash -c 'export TERM=xterm-256color COLUMNS=80 LINES=24; exec bash'
fi
