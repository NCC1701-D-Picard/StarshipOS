#!/bin/bash


set -e  # Exit on any error
set -u  # Treat unset variables as errors

MAKE_DIR="linux"
HUMAN_NAME="StarshipOS kernel"

function log() {
    echo "[CLEAN: $HUMAN_NAME: $(date +'%Y-%m-%d %H:%M:%S')] $1"
}

function clean() {
  if [ -d "./build" ]; then
    touch "module.log"
    rm "module.log"
    cd "$MAKE_DIR"
    make clean
    make mrproper
    make defconfig
    cd "../"
  fi
}

function super_clean() {
  if [ -d "./build" ]; then
    touch "module.log"
    rm "module.log"
    cd "$MAKE_DIR"
    make clean
    make mrproper
    make defconfig
    cd "../"
    sudo rm -rfv --force "build" # Uncomment to build kernel every time.
  fi
}

function main() {
  local clean_mode="clean"  # Default to "clean"

  # Check for arguments
  if [[ $# -gt 0 ]]; then
    case "$1" in
      --super-clean)
        clean_mode="super_clean"
        ;;
      *)
        echo "Usage: $0 [--super-clean]"
        exit 1
        ;;
    esac
  fi

  log "Starting $HUMAN_NAME cleanup."

  if [[ "$clean_mode" == "super_clean" ]]; then
    super_clean
    log "Super clean completed for $HUMAN_NAME."
  else
    clean
    log "Clean completed for $HUMAN_NAME."
  fi
}

main "$@"
