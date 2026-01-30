#!/bin/bash

# Set david's password
if [ -n "$DAVID_PASSWORD" ]; then
    echo "david:$DAVID_PASSWORD" | chpasswd
else
    # Temporary password + force change on first login
    echo "david:david" | chpasswd
    chage -d 0 david
fi

# Fix ownership of mounted volumes for david
chown -R david:david /home/david/.claude 2>/dev/null || true
chown -R david:david /home/david/.takopi 2>/dev/null || true

# Start SSH in background
/usr/sbin/sshd

# Start takopi as david user if config exists
if [ -f /home/david/.takopi/takopi.toml ]; then
    echo "Starting takopi..."
    su - david -c "takopi >> /home/david/.takopi/takopi.log 2>&1 &"
fi

# Execute main command
exec "$@"
