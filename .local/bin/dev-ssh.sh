#!/bin/bash

# Connects to my remote dev machine via ssh, starting the instance automatically if needed.
set -e

# all other gcloud crap (region, zone, project, auth) must already be configured in gcloud
# gcloud config set compute/region us-central1
# gcloud config set compute/zone us-central1-a
# gcloud config set project foo
VM_NAME="phil-dev"

function log() {
    echo "$@" 1>&2
}

function get_status() {
    gcloud compute instances describe "$VM_NAME" --format='value(status)'
}

function await_status() {
    local attempts=0
    local current_status="$STATUS"
    while [[ "$current_status" !=  "$1" ]]; do
        log "current_status=$current_status awaiting=$1"
        ((attempts+=1))
        sleep 3
        if [[ "$attempts" -gt 10 ]]; then
            log "failed to reach status: $1"
            exit 1
        fi
    done
    log "instance has status: $1"
}

# STATUS variable also read inside await_status so I don't have to get it twice
STATUS="$(get_status)"
if [[ "$STATUS" != "RUNNING" ]]; then
    # If it's not running, then it could be in the process of stopping, and we'd need to wait for it
    # to finish shutting down before attempting to start again.
    await_status "TERMINATED"
    gcloud compute instances start "$VM_NAME"
fi


VM_IP="$(gcloud compute instances describe "$VM_NAME" --format='get(networkInterfaces[0].accessConfigs[0].natIP)')"
if [[ -z "$VM_IP" ]]; then
    log "failed to get instance ip"
    exit 1
fi

# Even after the instance is "RUNNING" ('instances start' seems to wait for that automatically), it
# can take a bit of time for sshd to be listening, and for gcp's network to start routing traffic to
# it. Wait until it can establish a connection using netcat before trying ssh.
ATTEMPT=0
while [[ "$ATTEMPT" -le 20 ]]; do
    nc -w 5 "$VM_IP" 22 < /dev/null &>/dev/null && break
    log waiting for "$VM_IP:22" to accept connections
    sleep 3
done

# finally ready to connect
ssh -i ~/.ssh/phil-estuary-rsa phil@"$VM_IP"
