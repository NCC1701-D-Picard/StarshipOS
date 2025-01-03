#!/bin/bash
# shellcheck disable=SC2164

set -e  # Exit immediately if a command exits with a non-zero status
set -u  # Treat unset variables as an error

BLOCK_DEVICE=$1
BUILD_DIR="build/$BLOCK_DEVICE/boot"

function log() {
    echo "[grub: INFO: $(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "../module.log"
}

log "Starting GRUB configuration script."

if [ ! -d "$BUILD_DIR" ]; then
    log "Creating build directory: $BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    cp -r src/* build/
    log "Successfully created GRUB configuration file."
else
    log "Build directory already exists. Skipping creation."
fi

log "Finished GRUB configuration script."
cat "../module.log" >> "../../build.log"