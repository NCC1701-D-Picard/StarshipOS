#!/bin/bash
# shellcheck disable=SC2164

set -e  # Exit immediately if a command exits with a non-zero status
set -u  # Treat unset variables as an error

MODULE_HOME=$(pwd)
BUILD_DIR="$MODULE_HOME/build"
#KERNEL_HEADERS="$MODULE_HOME/target/kernel/build/usr"
TEMP_BUILD="/tmp/build"
TEMP_STAGING="/tmp/staging"

function log() {
    echo "[glibc: INFO: $(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "../module.log"
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
  ../configure --prefix="$TEMP_STAGING/" --disable-multi-arch
  # shellcheck disable=SC2046
  make -j$(nproc)
  sudo make DESTDIR="$TEMP_STAGING" install
  if [ -n "$(find "$TEMP_STAGING" -mindepth 1)" ]; then
    log "Creating tarball for Glibc installation from staging directory: $TEMP_STAGING"
    # Ensure $BUILD_DIR exists
    mkdir -p "$BUILD_DIR"
    # Create a tarball that compresses the contents of $TEMP_STAGING
    tar -cpvzf "$BUILD_DIR/glibc-2.31.tgz" -C "$TEMP_STAGING" .
    # Check if the tarball was successfully created
    if [ -f "$BUILD_DIR/glibc-2.31.tgz" ]; then
      log "Tarball successfully created at $BUILD_DIR/glibc-2.31.tgz."
    else
    log "Error: Failed to create Glibc tarball."
  fi
else
  log "Error: Staging directory $TEMP_STAGING is empty. Aborting tarball creation."
fi
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
