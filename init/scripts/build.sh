#!/bin/bash
# Exit on errors or unset variables

set -e
set -u

function log() {
    echo "[system-bridge: $(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log "$(figglet "system-bridge")"
log "Coming soon!"
