#!/bin/bash

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

# Log function
function log() {
    echo "[BUILD: $(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log "Ensuring proper build directory structure."
> module,log
# Build steps (make modules, headers, kernel)
if [ ! -d "$BUILD_DIR" ]; then
    mkdir -p "$BUILD_DIR"

    # Install kernel configuration
    cp -pv "$(pwd)/src/lockdown_config" "$KERNEL_SRC_DIR/.config"

    # Enter kernel source directory
    cd "$KERNEL_SRC_DIR"

    log "Building kernel and modules..."
    make olddefconfig
    make -j"$(nproc)" bzImage
    make modules
    make headers_install INSTALL_HDR_PATH="$BUILD_DIR/usr"  # For headers

    log "Installing modules..."
    export INSTALL_MOD_PATH="$BUILD_DIR"
    sudo make INSTALL_MOD_PATH="$INSTALL_MOD_PATH" modules_install

    # Copy kernel binary
    mkdir -p "$BUILD_DIR/boot"
    cp "arch/x86_64/boot/bzImage" "$BUILD_DIR/boot/$KERNEL_NAME"
    cd ..
fi

# Ownership: Handle symlinks without dereferencing
log "Adjusting ownership..."
sudo chown -R "$(whoami):$(whoami)" build

# Convert absolute symlinks to relative symlinks
find build -type l | while IFS= read -r symlink; do
    target=$(readlink "$symlink")  # Get the target of the symlink
    if [[ "$target" = /* ]]; then
        relative_target=$(realpath --relative-to="$(dirname "$symlink")" "$target")
        ln -sf "$relative_target" "$symlink"
        echo "Converted \"$symlink\" -> \"$relative_target\""
    fi
done

log "Build directory setup complete. Ready for Maven assembly."
cd "build"
tar -cvpzf "../$KERNEL_NAME.tgz" "./"
cd "../"

#cat "./module.log" >> "../../build.log"
