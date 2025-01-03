#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

MAKE_DIR="build"

function log() {
    echo "[gnu-tools: $(date +'%Y-%m-%d %H:%M:%S')] CLEAN: $1" >&2
}

log "Cleaning gnu-tools"

# Check if the directory exists before changing into it
  if [ -d "$MAKE_DIR" ]; then
    log "clean build directory."
  sudo rm -rfv "coreutils-9.4"
  sudo rm -rfv "e2fsprogs-1.47.0"
  sudo rm -rfv "bash-5.2.15"
  sudo rm -rfv "util-linux-2.39"
  # uncomment these to build gnu-tools every time.
#    sudo rm "build/gnu-tools/bin/bashbug"
#    sudo rm -rf "build" # uncomment to build every time.
else
    log "The directory is clean."
fi
touch ../module.log