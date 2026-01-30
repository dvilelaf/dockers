#!/bin/bash

# Set david's password
if [ -n "$DAVID_PASSWORD" ]; then
    echo "david:$DAVID_PASSWORD" | chpasswd
else
    # Temporary password + force change on first login
    echo "david:david" | chpasswd
    chage -d 0 david
fi

# Start SSH in background
/usr/sbin/sshd

# Execute main command
exec "$@"
