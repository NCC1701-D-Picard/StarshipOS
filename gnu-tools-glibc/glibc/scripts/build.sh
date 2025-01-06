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
    echo "[glibc: INFO: $(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "../module.log"
}

function pause() {
  echo "Paused, press [ENTER] to continue..."
  # shellcheck disable=SC2162
  read -p "x"
}

function build_glibc() {
  mkdir -p "$BUILD_DIR"
  sudo rm -rf "$TEMP_BUILD"
  sudo rm -rf "$TEMP_STAGING"
  mkdir -p /tmp/build
  cd /tmp/build
  wget http://ftp.gnu.org/gnu/libc/glibc-2.31.tar.gz
  tar -xvf glibc-2.31.tar.gz
  cd glibc-2.31
  mkdir -p ./build
  cd build
  ../configure --prefix="/" --disable-multi-arch
  make -j$(nproc)
  make DESTDIR="$TEMP_STAGING" install
  if [ -n "$(find "$TEMP_STAGING" -mindepth 1)" ]; then
    cd "$TEMP_STAGING"
    tar -cvpzf "$TEMP_BUILD/glibc-2.31-1.46.5.tar.gz" .
  else
    log "Error: $TEMP_STAGING is empty. No archive will be created."
  fi
  cd "../"
  mv "/tmp/build/glibc-2.31.tar.gz" "$MODULE_HOME/build/glibc-2.31.tgz"
  cd "$MODULE_HOME"
}

main() {
  log "********************************************************************************"
  log "*                                Building glibc ...                            *"
  log "********************************************************************************"

  if [ ! -d "$BUILD_DIR" ]; then
    log "Creating build directory: $BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    build_glibc
  else
    log "Build directory already exists. Will NOT rebuild."
  fi
  log "********************************************************************************"
  log "*                              Finished building glibc ...                     *"
  log "********************************************************************************"
  cat "../module.log" >> "../../build.log"
}

main "$@"
