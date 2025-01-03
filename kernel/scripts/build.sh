#!/bin/bash
#
# Copyright (c) 2024-2025.
#

echo "********************************************************************************"
echo "* bin/cleanbuild.sh --help for options                                         *"
echo "********************************************************************************"
# shellcheck disable=SC2164
# shellcheck disable=SC2162
# shellcheck disable=SC2046
# shellcheck disable=SC2034
# shellcheck disable=SC2155

set -e  # Exit immediately if a command exits with a non-zero status
set -u  # Treat unset variables as an error

# Define paths and environment
KERNEL_SRC_DIR="$(pwd)/linux"
BUILD_DIR="$(pwd)/build"
KERNEL_NAME="NCC1701-D"


# Logging function to show progress
function log() {
    echo "[kernel: $(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "../module.log"
}

function pause() {
  log "Paused, press [ENTER] to continue ..."
  read -p "x"
}

# Start the script workflow
log "Starting kernel build script."

# Check if $BUILD_DIR exists
if [ ! -d "$BUILD_DIR" ]; then
    log "No build directory detected. Starting kernel build process."
    mkdir -p "build"
    # Ensure kernel directory exists before proceeding
    if [ ! -d "$KERNEL_SRC_DIR" ]; then
        log "Kernel source directory does not exist: $KERNEL_SRC_DIR"
        log "Exiting script as there is no source to build."
    fi
    # TODO Lock in our own kernel configuration later.
    cp -pv "$(pwd)/src/lockdown_config" "$(pwd)/linux/.config" # The .config in the module root should ALWAYS be working.

    # Enter kernel directory
    cd "$KERNEL_SRC_DIR"
    log "Building the Starship kernel in $KERNEL_SRC_DIR."
    make -j"$(nproc)" bzImage 2>&1 | tee -a "../module.log"

    export INSTALL_MOD_PATH="$BUILD_DIR/lib"
    log "Creating install path: $INSTALL_MOD_PATH"

    log "Compiling kernel modules."
    make modules 2>&1 | tee -a "../module.log"

    log "Installing modules into: $INSTALL_MOD_PATH"
    mkdir -p "$INSTALL_MOD_PATH"
    sudo make INSTALL_MOD_PATH="$INSTALL_MOD_PATH" modules_install

    # Copy kernel to boot directory
    log "Preparing boot directory: ${BUILD_DIR}/boot"
    mkdir -p "${BUILD_DIR}/boot"

    log "Copying bzImage (kernel) to ${BUILD_DIR}/boot/$KERNEL_NAME."
    cp -p "arch/x86_64/boot/bzImage" "${BUILD_DIR}/boot/$KERNEL_NAME"

    cd ../ # Back to module root

    log "Kernel build and installation completed successfully."
else
    # Skip build if $BUILD_DIR already exists
    log "Build directory already exists. Skipping kernel build."
fi
# Dereference symlinks & change owbership/
sudo chown -RL --dereference "$(whoami):$(whoami)" "build"
# Append logs
cat ../module.log >> ../../build.log
log "Build starship kernel complete."
