#!/bin/bash

# Used as the startup-script in gcp dev instance to automatically shutdown the instance after an
# idle period.
IDLE_COUNT=0
while true; do
    USER_COUNT="$(who | wc -l)"
    if [[ "$USER_COUNT" -eq 0 ]]; then
        ((IDLE_COUNT+=1))
    else
        IDLE_COUNT=0
    fi

    # 12 * 300 seconds = 1 hour
    if [[ "IDLE_COUNT" -gt 12 ]]; then
        echo "Stopping phil's idle instance"
        sudo shutdown -h now
    fi
    sleep 300
done
