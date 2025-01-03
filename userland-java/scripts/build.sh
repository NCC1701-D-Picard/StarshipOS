#!/bin/bash
figglet ""
#!/bin/bash
# Exit on errors or unset variables

set -e
set -u

function log() {
    echo "[userland-java: $(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log "$(figglet "userland-java")"
log "Coming soon!"
