#!/usr/bin/env bash
set -euo pipefail

# Ensure SSH host keys exist (regenerated on first boot if missing)
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -A
fi

# Lock down authorized_keys permissions if present
if [ -f /root/.ssh/authorized_keys ]; then
    chmod 600 /root/.ssh/authorized_keys
    chown root:root /root/.ssh/authorized_keys
fi

# If KILO_API_KEY is provided as a Fly secret, log confirmation
# (Kilo CLI reads it automatically from the environment on its next invocation)
if [ -n "${KILO_API_KEY:-}" ]; then
    echo "✓ KILO_API_KEY is set (length: ${#KILO_API_KEY})"
else
    echo "⚠ KILO_API_KEY is not set. Run: flyctl secrets set KILO_API_KEY=<key>"
fi

# Keep projects mount owned by root (matches container user)
if [ -d /root/projects ]; then
    chown root:root /root/projects || true
fi

echo "Starting SSH daemon on port 2222..."
exec /usr/sbin/sshd -D -p 2222
