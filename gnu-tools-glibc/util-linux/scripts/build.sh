#!/bin/bash
# shellcheck disable=SC2164

set -e  # Exit immediately if a command exits with a non-zero status
set -u  # Treat unset variables as an error

MODULE_HOME=$(pwd)
BUILD_DIR="build"
KERNEL_HEADERS="$(pwd)/target/kernel/build/usr"
TEMP_BUILD="/tmp/build"
TEMP_STAGING="/tmp/staging"

function log() {
    echo "[linux-util: INFO: $(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "../module.log"
}

function pause() {
  echo "Paused, press [ENTER] to continue..."
  # shellcheck disable=SC2162
  read -p "x"
}

function build_util_linux() {
  sudo rm -rf "$TEMP_BUILD"
  sudo rm -rf "$TEMP_STAGING"
  mkdir -p /tmp/build
  cd /tmp/build
  wget https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v2.39/util-linux-2.39.1.tar.gz
  tar -xvf util-linux-2.39.1.tar.gz
  cd util-linux-2.39.1
  ./configure --prefix="/" 2>&1 | tee -a "../module.log"
  # shellcheck disable=SC2046
  make -j$(nproc) 2>&1 | tee -a "../module.log"
  make -j$(nproc)
  sudo make install
  if [ -n "$(find "$TEMP_STAGING" -mindepth 1)" ]; then
    cd "$TEMP_STAGING"
    tar -cvpzf "$TEMP_BUILD/util-linux-2.39.1.tar.gz" .
  else
    log "Error: $TEMP_STAGING is empty. No archive will be created."
  fi
  cd "../"
  mv "/tmp/build/util-linux-2.39.1.tar.gz" "$MODULE_HOME/build/util-linux-2.39.1.tgz"
  cd "$MODULE_HOME"
}

main() {
  log "********************************************************************************"
  log "*                             Building linux-util ...                          *"
  log "********************************************************************************"

  if [ ! -d "$BUILD_DIR" ]; then
    log "Creating build directory: $BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    build_util_linux
  else
    log "Build directory already exists. Will NOT rebuild."
  fi
  log "********************************************************************************"
  log "*                             Building linux-util ...                          *"
  log "********************************************************************************"
  cat "../module.log" >> "../../build.log"
}

main "$@"
