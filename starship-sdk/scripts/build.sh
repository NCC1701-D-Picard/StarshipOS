#!/bin/bash
# Exit on errors or unset variables

set -e
set -u

function log() {
    echo "[starship SDK: $(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log "$(figglet "Starship-SDK")"
log "Coming soon!"
