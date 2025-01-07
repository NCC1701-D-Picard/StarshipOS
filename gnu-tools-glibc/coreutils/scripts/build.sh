#!/bin/bash
# shellcheck disable=SC2164

set -e  # Exit immediately if a command exits with a non-zero status
set -u  # Treat unset variables as an error

MODULE_HOME=$(pwd)
BUILD_DIR="$MODULE_HOME/build"
KERNEL_HEADERS="MODULE_HOME/target/kernel/build/usr"
TEMP_BUILD="/tmp/build"
TEMP_STAGING="/tmp/staging"

function log() {
    echo "[coreutils: INFO: $(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "../module.log"
}

function pause() {
  echo "Paused, press [ENTER] to continue..."
  # shellcheck disable=SC2162
  read -p "x"
}

function build_coreutils() {
  sudo rm -rf "$TEMP_BUILD"
  sudo rm -rf "$TEMP_STAGING"
    mkdir -p /tmp/build
    cd /tmp/build
    wget http://ftp.gnu.org/gnu/coreutils/coreutils-9.2.tar.xz
    tar -xvf coreutils-9.2.tar.xz
    cd coreutils-9.2
    ./configure --prefix="/"
    make -j$(nproc)
    make DESTDIR="/tmp/staging" install
  if [ -n "$(find "$TEMP_STAGING" -mindepth 1)" ]; then
    cd "$TEMP_STAGING"
    tar -cvpzf "$TEMP_BUILD//coreutils-9.2.tar.gz" .
  else
    log "Error: $TEMP_STAGING is empty. No archive will be created."
  fi
  cd "../"
  mv "/tmp/build/coreutils-9.2.tar.gz" "$MODULE_HOME/build//coreutils-9.2.tgz"
    sudo rm -rf "$TEMP_BUILD"
    sudo rm -rf "$TEMP_STAGING"

  cd "$MODULE_HOME"
}

main() {
  log "********************************************************************************"
  log "*                              Building coreutils ...                          *"
  log "********************************************************************************"

  if [ ! -d "$BUILD_DIR" ]; then
    log "Creating build directory: $BUILD_DIR"
    mkdir -p "$BUILD_DIR"
  build_coreutils
  else
    log "Build directory already exists. Will NOT rebuild."
  fi
  log "********************************************************************************"
  log "*                              Building coreutils ...                          *"
  log "********************************************************************************"
  cat "../module.log" >> "../../build.log"
}

main "$@"

