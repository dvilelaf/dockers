#!/bin/bash

# Set david's password
if [ -n "$DAVID_PASSWORD" ]; then
    echo "david:$DAVID_PASSWORD" | chpasswd
else
    # Temporary password + force change on first login
    echo "david:david" | chpasswd
    chage -d 0 david
fi

# Set david's SSH private key for outbound authentication (GitHub, etc.)
# Key should be base64 encoded in DAVID_SSH_PRIVATE_KEY_B64
if [ -n "$DAVID_SSH_PRIVATE_KEY_B64" ]; then
    echo "$DAVID_SSH_PRIVATE_KEY_B64" | base64 -d > /home/david/.ssh/id_ed25519
    chmod 600 /home/david/.ssh/id_ed25519
    chown david:david /home/david/.ssh/id_ed25519
    echo "SSH private key configured for david"
fi

# Fix ownership of mounted volumes for david
chown -R david:david /home/david/.claude 2>/dev/null || true
chown -R david:david /home/david/.config 2>/dev/null || true

# Start SSH in background
/usr/sbin/sshd

# Execute main command
exec "$@"
