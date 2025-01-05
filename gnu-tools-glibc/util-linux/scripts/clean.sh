#!/bin/bash
# shellcheck disable=SC2164

set -e  # Exit immediately if a command exits with a non-zero status
set -u  # Treat unset variables as an error

BUILD_DIR="build"

function log() {
    echo "[util-linux: CLEAN: $(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "../module.log"
}



main() {
  log "********************************************************************************"
  log "*                            Cleaning linux-util ...                           *"
  log "********************************************************************************"

  if [ -d "$BUILD_DIR" ]; then
    log "Cleaning build directory: $BUILD_DIR"
    rm -rfv -- force "$BUILD_DIR"
  else
    log "Build directory already exists. Will NOT rebuild."
  fi
  log "********************************************************************************"
  log "*                            Cleaning linux-util ...                           *"
  log "********************************************************************************"
  cat "../module.log" >> "../../build.log"
}

main "$@"


