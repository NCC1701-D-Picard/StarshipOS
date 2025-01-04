#!/bin/bash

#
# /*
#  * Copyright (c) ${YEAR}.
#  *
#  * Project Name: StarshipOS
#  * Developed by: ${USER}
#  *
#  * Licensed under the terms and conditions described in the project documentation.
#  *
#  * File Name: ${NAME}
#  * Created Date: ${DATE}
#  * Author: ${USER}
#  */
#

set -e  # Exit on any error
set -u  # Treat unset variables as errors
set +x
# Helper Functions
function log() {
    echo "[gnu-tools-glibc: $(date +'%Y-%m-%d %H:%M:%S')] $1"
}

function pause() {
    log "Paused, press [ENTER] to continue..."
    # shellcheck disable=SC2162
    read -p "x"
}

function package_unified_system() {
    local build_dir="/home/rajames/PROJECTS/StarshipOS/gnu-tools-glibc/build"

    log "Starting packaging process for the unified system..."

    # Define the output tarball name
    local tarball_name="unified-system.tar.gz"

    # Check if the /tmp/build directory exists
    if [ ! -d "/tmp/build" ]; then
        log "ERROR: '/tmp/build' directory does not exist! Exiting."
        exit 1
    fi

    # Create the tarball from the entire contents of /tmp/build
    log "Creating a tarball from the contents in '/tmp/build'..."
    tar -czvf "/tmp/$tarball_name" -C /tmp/build .

    # Verify tarball creation
    if [ ! -f "/tmp/$tarball_name" ]; then
        log "ERROR: Failed to create the tarball! Exiting."
        exit 1
    else
        log "Tarball successfully created: /tmp/$tarball_name"
    fi

    # Ensure the GNU Tools build directory exists
    mkdir -p "$build_dir"

    # Move the tarball to the build_dir
    log "Moving tarball to $build_dir..."
    mv "/tmp/$tarball_name" "$build_dir/"

    # Verify the tarball was successfully moved
    if [ -f "$build_dir/$tarball_name" ]; then
        log "Tarball successfully moved to $build_dir."
    else
        log "ERROR: Failed to move the tarball to $build_dir. Exiting."
        exit 1
    fi

    # Clean up (if needed: optional — can be disabled during testing)
    log "Cleaning up temporary build directory (/tmp/build)..."
    rm -rf /tmp/build

    log "Packaging process completed successfully."
}

function cleanup() {
    log "Cleaning up staging directory: /tmp/staging..."
    rm -rf --force /tmp/staging
    rm -rf --force /tmp/build
}

### Build Functions ###
function build_glibc() {
  log "********************************************************************************"
  log "*                               Building glibc ...                             *"
  log "********************************************************************************"

    # Step 1: Install Kernel Headers (Ensure headers are prepared beforehand)
#    KERNEL_HEADERS_DIR="build/kernel-headers"
#    mkdir -p "$KERNEL_HEADERS_DIR"
#    cd /path/to/linux-source
#    make headers_install INSTALL_HDR_PATH="$KERNEL_HEADERS_DIR"
    mkdir -p /tmp/build
    cd /tmp/build
    wget http://ftp.gnu.org/gnu/libc/glibc-2.31.tar.gz
    tar -xvf glibc-2.31.tar.gz
    cd glibc-2.31
    mkdir -p ./build
    cd build
    ../configure --prefix="/" --disable-multi-arch #--with-headers="$KERNEL_HEADERS_DIR"
    make -j4
    make DESTDIR="/tmp/staging" install

    cd /tmp/build
    log "Finished building glibc."
}

function build_e2fsprogs() {
    log "********************************************************************************"
    log "*                             Building e2fsprogs ...                           *"
    log "********************************************************************************"

    mkdir -p /tmp/build
    cd /tmp/build
    wget https://mirrors.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v1.46.5/e2fsprogs-1.46.5.tar.gz
    tar -xvf e2fsprogs-1.46.5.tar.gz
    cd e2fsprogs-1.46.5
    ./configure --prefix="/" --enable-elf-shlibs
    make -j4
    make DESTDIR="/tmp/staging" install

    cd /tmp/build
    log "Finished building e2fsprogs."
}

function build_coreutils() {
    log "********************************************************************************"
    log "*                            Building coreutils ...                            *"
    log "********************************************************************************"

    mkdir -p /tmp/build
    cd /tmp/build
    wget http://ftp.gnu.org/gnu/coreutils/coreutils-9.2.tar.xz
    tar -xvf coreutils-9.2.tar.xz
    cd coreutils-9.2
    ./configure --prefix="/"
    make -j4
    make DESTDIR="/tmp/staging" install

    cd /tmp/build
    log "Finished building coreutils."
}

function build_bash() {
    log "********************************************************************************"
    log "*                          Building bash ...                                   *"
    log "********************************************************************************"

    mkdir -p /tmp/build
    cd /tmp/build
    wget http://ftp.gnu.org/gnu/bash/bash-5.2.tar.gz
    tar -xvf bash-5.2.tar.gz
    cd bash-5.2
    ./configure --prefix="/"
    make -j4
    make DESTDIR="/tmp/staging" install

    cd /tmp/build
    log "Finished building bash."
}

function build_util_linux() {
    log "********************************************************************************"
    log "*                       Building util-linux ...                                *"
    log "********************************************************************************"

    mkdir -p /tmp/build
    cd /tmp/build
    wget https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v2.39/util-linux-2.39.1.tar.gz
    tar -xvf util-linux-2.39.1.tar.gz
    cd util-linux-2.39.1
    ./configure --prefix="/" 2>&1 | tee -a "../module.log"
    # shellcheck disable=SC2046
    make -j$(nproc) 2>&1 | tee -a "../module.log"
    sudo make install 2>&1 | tee -a "../module.log"
    cd /tmp/build
    log "Finished building util-linux."
}

### Main Script Execution ###
function main() {
    # Early Exit Condition: Check if /tmp/build already exists
    if [ ! -d "build" ]; then
    log "Preparing build environment..."
    mkdir -p /tmp/staging  # Always create the staging directory

    # Build all packages and install into a unified directory
    build_glibc
    build_util_linux
    build_coreutils
    build_e2fsprogs # Build BEFORE bash!
    build_bash

    # Package into unified tarball
    package_unified_system

    # Clean up the staging directory
    cleanup

    log "Build complete!"
fi
}

main "$@"
