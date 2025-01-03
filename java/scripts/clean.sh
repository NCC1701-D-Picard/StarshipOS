#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

MAKE_DIR="jdk"

function log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

function error_log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1" >&2
}

# Check if the directory exists before changing into it
#if [ -d "$MAKE_DIR" ]; then
#  rm "module.log"
        log "Moving into $MAKE_DIR"
        cd "$MAKE_DIR" || { error_log "Failed to change directory to $MAKE_DIR"; exit 1; }

        log "Cleaning with make clean in $MAKE_DIR"
        make CONF="linux-x86_64-server-release" clean || { error_log "make clean failed"; exit 1; }
        cd "../"
#else
#    log "The directory $MAKE_DIR does not exist."
#fi
