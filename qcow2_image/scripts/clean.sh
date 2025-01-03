#!/bin/bash

# shellcheck disable=SC2164

set -e  # Exit immediately if a command exits with a non-zero status
set -u  # Treat unset variables as an error

BUILD_DIR="build"

function log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log "QCOW2 will be 'Uber-clean'."
if [ -d "$BUILD_DIR" ]; then
#  rm "module.log"
  if [ -f "starship-os.raw" ]; then
    sudo umount "build/root"
    sudo losetup -d "$(sudo losetup --find --show --partscan "build/starship-os.raw")"
fi
  sudo rm -rf "$BUILD_DIR/boot" "$BUILD_DIR/root"
else
  log "Nothing to do."
fi

log "QCOW2 will be rebuilt every run."
