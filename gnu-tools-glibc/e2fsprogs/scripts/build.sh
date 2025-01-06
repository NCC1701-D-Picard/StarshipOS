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
    echo "[e2fsprogs: INFO: $(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "../module.log"
}

function pause() {
  echo "Paused, press [ENTER] to continue..."
  # shellcheck disable=SC2162
  read -p "x"
}

function build_e2fsprogs() {
  sudo rm -rf "$TEMP_BUILD"
  sudo rm -rf "$TEMP_STAGING"
  mkdir -p /tmp/build
  cd /tmp/build
  wget https://mirrors.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v1.46.5/e2fsprogs-1.46.5.tar.gz
  tar -xvf e2fsprogs-1.46.5.tar.gz
  cd e2fsprogs-1.46.5
  ./configure --prefix="/" --enable-elf-shlibs
  make -j4
  make DESTDIR="$TEMP_STAGING" install
  if [ -n "$(find "$TEMP_STAGING" -mindepth 1)" ]; then
    cd "$TEMP_STAGING"
    tar -cvpzf "$TEMP_BUILD/e2fsprogs-1.46.5.tar.gz" .
  else
    log "Error: $TEMP_STAGING is empty. No archive will be created."
  fi
  cd "../"
  mv "/tmp/build/e2fsprogs-1.46.5.tar.gz" "$MODULE_HOME/build/e2fsprogs-1.46.5.tgz"
  cd "$MODULE_HOME"
}

main() {
  log "********************************************************************************"
  log "*                              Building e2fsprogs ...                          *"
  log "********************************************************************************"

  if [ ! -d "$BUILD_DIR" ]; then
    log "Creating build directory: $BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    build_e2fsprogs
  else
    log "Build directory already exists. Will NOT rebuild."
  fi
  log "********************************************************************************"
  log "*                             Building e2fsprogs ...                          *"
  log "********************************************************************************"
  cat "../module.log" >> "../../../build.log"
}

main "$@"
