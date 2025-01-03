#!/bin/bash

# shellcheck disable=SC2164

set -e  # Exit immediately if a command exits with a non-zero status
set -u  # Treat unset variables as an error

BUILD_DIR="build"

function log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log "initramfs will be 'Uber-clean'."
if [ -d "$BUILD_DIR" ]; then
  rm "build.log"
  sudo rm -fv $BUILD_DIR/initrd/dev/sda $BUILD_DIR/initrd/dev/console
  sudo rm -fv $BUILD_DIR/initrd/dev/sda $BUILD_DIR/initrd/dev/sda
  sudo rm -rfv "$BUILD_DIR"
else
  echo "Nothing to do."
fi

echo "initramfs will be rebuilt every run."
