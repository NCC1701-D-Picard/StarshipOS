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
  sudo rm -rf "$TEMP_BUILD"
  sudo rm -rf "$TEMP_STAGING"
  mkdir -p /tmp/build
  cd /tmp/build
  wget http://ftp.gnu.org/gnu/libc/glibc-2.31.tar.gz
  tar -xvf glibc-2.31.tar.gz
  cd glibc-2.31
  mkdir -p ./build
  cd build
  echo "$KERNEL_HEADERS"
  echo "$MODULE_HOME"
  pause
  ../configure --prefix="/" --disable-multi-arch --with-headers="$BUILD_DIR/usr/include" --enable-kernel=6.12 libc_cv_have_selinux=no

  make -j$(nproc)
  make DESTDIR="$TEMP_STAGING" install
   ls "$TEMP_STAGING"
pause
#    cd /tmp/staging
#    tar -cvpzf glibc-2.31.tar.gz .
#    mv glibc-2.31.tar.gz /home/rajames/PROJECTS/StarshipOS/gnu-tools-glibc/glibc/build
#    log "Finished building glibc."
}

main() {
  log "********************************************************************************"
  log "*                                Building glibc ...                            *"
  log "********************************************************************************"

  if [ ! -d "$BUILD_DIR" ]; then
    log "Creating build directory: $BUILD_DIR"
#    mkdir -p "$BUILD_DIR"
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
