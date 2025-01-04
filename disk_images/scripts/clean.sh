#!/bin/bash

# shellcheck disable=SC2164

set -e  # Exit immediately if a command exits with a non-zero status
set -u  # Treat unset variables as an error

BUILD_DIR="build"

function log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log "disk_images will be 'Uber-clean'."
if [ -d "$BUILD_DIR" ]; then
  if [ -f "starship-os.raw" ]; then
    sudo umount "build/rootfs"
    sudo losetup -d "$(sudo losetup --find --show --partscan "build/starship-os.raw")"
fi
  sudo rm -rfv "$BUILD_DIR"
  sudo rm -rfv "./target"
else
  log "Nothing to do."
fi

log "disk_images will be rebuilt every run."
