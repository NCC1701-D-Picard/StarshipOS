#!/bin/bash
# shellcheck disable=SC2164

set -e  # Exit immediately if a command exits with a non-zero status
set -u  # Treat unset variables as an error

BUILD_DIR="build"

function log() {
    echo "[e2fsprogs: INFO: $(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "../module.log"
}

function pause() {
  echo "Paused, press [ENTER] to continue..."
  # shellcheck disable=SC2162
  read -p "x"
}


main() {
  log "********************************************************************************"
  log "*                              Building e2fsprogs ...                          *"
  log "********************************************************************************"

  if [ ! -d "$BUILD_DIR" ]; then
    log "Creating build directory: $BUILD_DIR"
    mkdir -p "$BUILD_DIR"
pause
  else
    log "Build directory already exists. Will NOT rebuild."
  fi
  log "********************************************************************************"
  log "*                             Building e2fsprogs ...                          *"
  log "********************************************************************************"
  cat "../module.log" >> "../../../build.log"
}

main "$@"
