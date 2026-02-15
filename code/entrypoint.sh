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

# Remove stale takopi lock file
TAKOPI_LOCK="/home/david/.takopi/takopi.lock"
if [ -f "$TAKOPI_LOCK" ]; then
    lock_pid=$(python3 -c "import json; print(json.load(open('$TAKOPI_LOCK'))['pid'])" 2>/dev/null)
    if [ -n "$lock_pid" ] && ! kill -0 "$lock_pid" 2>/dev/null; then
        echo "Removing stale takopi lock (PID $lock_pid not running)"
        rm -f "$TAKOPI_LOCK"
    fi
fi

# Start takopi with watchdog that restarts it if it crashes
if [ -f /home/david/.takopi/takopi.toml ]; then
    export PATH="/home/david/.claude/local/bin:/home/david/.local/bin:$PATH"
    (
        cd /home/david
        while true; do
            rm -f "$TAKOPI_LOCK"
            echo "$(date -Iseconds) Starting takopi..." >> /home/david/.takopi/takopi.log
            runuser -u david -- env PATH="$PATH" /home/david/.local/bin/takopi >> /home/david/.takopi/takopi.log 2>&1
            echo "$(date -Iseconds) takopi exited (code $?), restarting in 10s..." >> /home/david/.takopi/takopi.log
            sleep 10
        done
    ) &
    echo "takopi watchdog started"
fi

# Execute main command
exec "$@"
