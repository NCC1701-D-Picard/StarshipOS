#!/bin/bash
# shellcheck disable=SC2164

set -e  # Exit immediately if a command exits with a non-zero status
set -u  # Treat unset variables as an error

MODULE_HOME=$(pwd)
BUILD_DIR="$MODULE_HOME/build"
#KERNEL_HEADERS="MODULE_HOME/target/kernel/build/usr"
TEMP_BUILD="/tmp/build"
TEMP_STAGING="/tmp/staging"

function log() {
    echo "[linux-util: INFO: $(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "../module.log"
}

function pause() {
  echo "Paused. Press [ENTER] to continue or [c] to open a shell..."

  # Read a single key from user input
  read -n1 -r key

  if [[ $key == "c" ]]; then
    echo -e "\nOpening a subshell. Type 'exit' to return."
    # Open a subshell
    bash
    echo "Returning from subshell..."
  fi

  # Pressing any other key (or ENTER) will continue the script
}

function build_util_linux() {
  sudo rm -rf "$TEMP_BUILD"
  sudo rm -rf "$TEMP_STAGING"
  mkdir -p /tmp/build
  cd /tmp/build
  wget https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v2.39/util-linux-2.39.1.tar.gz
  tar -xvf util-linux-2.39.1.tar.gz
  cd util-linux-2.39.1
  mkdir build
  cd build

  ../configure --prefix=$TEMP_STAGING/usr --disable-nls --enable-static --enable-shared --disable-profile --enable-runtime-checks 2>&1 | tee -a "../module.log"

  # shellcheck disable=SC2046
  make -j$(nproc) 2>&1 | tee -a "../module.log"
  sudo make install
  tar -cvpzf "$BUILD_DIR/util-linux-2.39.1.tgz" -C /tmp/build/util-linux-2.39.1/build . --transform='s,^,sbin/,'
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
