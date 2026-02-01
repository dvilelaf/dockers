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
chown david:david /workspace 2>/dev/null || true
chown -R david:david /home/david/.claude 2>/dev/null || true
chown -R david:david /home/david/.takopi 2>/dev/null || true

# Start SSH in background
/usr/sbin/sshd

# Start takopi as david user if config exists
if [ -f /home/david/.takopi/takopi.toml ]; then
    echo "Starting takopi..."
    cd /home/david
    export PATH="/home/david/.claude/local/bin:/home/david/.local/bin:$PATH"
    runuser -u david -- env PATH="$PATH" nohup /home/david/.local/bin/takopi >> /home/david/.takopi/takopi.log 2>&1 &
    sleep 2
    if pgrep -u david -f takopi > /dev/null; then
        echo "takopi started successfully (PID: $(pgrep -u david -f takopi))"
    else
        echo "WARNING: takopi failed to start, check ~/.takopi/takopi.log"
    fi
fi

# Execute main command
exec "$@"
