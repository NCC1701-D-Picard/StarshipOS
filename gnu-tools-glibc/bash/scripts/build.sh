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
    echo "[bash: INFO: $(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "../module.log"
}

function pause() {
  echo "Paused, press [ENTER] to continue..."
  # shellcheck disable=SC2162
  read -p "x"
}

function build_bash() {
  sudo rm -rf "$TEMP_BUILD"
  sudo rm -rf "$TEMP_STAGING"
  mkdir -p /tmp/build
  cd /tmp/build
  wget http://ftp.gnu.org/gnu/bash/bash-5.2.tar.gz
  tar -xvf bash-5.2.tar.gz
  cd bash-5.2
  ./configure --prefix="/"
  make -j$(nproc)
  make DESTDIR="/tmp/staging" install
  if [ -n "$(find "$TEMP_STAGING" -mindepth 1)" ]; then
    cd "$TEMP_STAGING"
    ls -al
pause
    tar -cvpzf "$TEMP_BUILD/bash-5.2.tar.gz" .
  else
    log "Error: $TEMP_STAGING is empty. No archive will be created."
  fi
  cd "../"
  mv "/tmp/build/bash-5.2.tar.gz" "$MODULE_HOME/build/bash-5.2.tgz"
  cd "$MODULE_HOME"
}

main() {
  log "********************************************************************************"
  log "*                                Building bash ...                             *"
  log "********************************************************************************"

  if [ ! -d "$BUILD_DIR" ]; then
    log "Creating build directory: $BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    build_bash
  else
    log "Build directory already exists. Will NOT rebuild."
  fi
  log "********************************************************************************"
  log "*                                Building bash ...                             *"
  log "********************************************************************************"
  cat "../module.log" >> "../../../build.log"
}

main "$@"
