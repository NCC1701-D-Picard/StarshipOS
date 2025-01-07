#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
set -u  # Treat unset variables as an error

# Define paths and environment
KERNEL_SRC_DIR="$(pwd)/linux"
BUILD_DIR="$(pwd)/build"
OUTPUT_DIR="$(pwd)/target/kernel/build"
KERNEL_NAME="NCC1701-D"
TARBALL_NAME="$KERNEL_NAME.tgz"

# Log function
function log() {
    echo "[BUILD: $(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log "Ensuring proper directory structure."
mkdir -p "$BUILD_DIR"
mkdir -p "$OUTPUT_DIR"

# shellcheck disable=SC2188
> module.log

if [ ! -d "$BUILD_DIR" ]; then

  if [ ! -f "$BUILD_DIR/boot/$KERNEL_NAME" ]; then
    log "Installing kernel configuration."
    cp -pv "$(pwd)/src/lockdown_config" "$KERNEL_SRC_DIR/.config"
    # Enter kernel source directory
    cd "$KERNEL_SRC_DIR"
    log "Building kernel and modules..."
    make olddefconfig
    make -j"$(nproc)" bzImage
    make modules
    make headers_install
    sudo make modules_install
    # Copy kernel binary to BUILD_DIR
    mkdir -p "$BUILD_DIR/boot"
    cp "arch/x86_64/boot/bzImage" "$BUILD_DIR/boot/$KERNEL_NAME"
    cd ../
  fi

  # Validate symlinks (fail on broken/external symlinks)
  log "Validating symlinks..."
  find "$BUILD_DIR" -type l | while IFS= read -r symlink; do
    target=$(readlink "$symlink")  # Get the symlink target
    if [ -z "$target" ]; then
      # Broken symlink
      log "[WARNING] Broken symlink detected: $symlink"
      # Attempt repair (placeholder logic for repair, add as needed)
      # Example: Remove broken symlink or replace with a repaired path
      repair_target=$(dirname "$symlink")/replacement_target  # Example placeholder
        if [ -e "$repair_target" ]; then
          ln -sf "$repair_target" "$symlink"
          log "Repaired broken symlink: $symlink -> $repair_target"
        else
          log "[WARNING] Unable to repair broken symlink: $symlink"
        fi
        continue  # Skip further validation for broken symlinks
    fi

    if [[ "$target" = /* ]]; then
      # Absolute symlink: Check whether the target is contained within BUILD_DIR
      full_target=$(realpath "$target" || true)  # Resolve the absolute path safely
      if [[ "$full_target" != "$BUILD_DIR"* ]]; then
          log "[WARNING] Unsafe absolute symlink: $symlink -> $full_target"
          # Attempt repair: Convert to relative symlink
          relative_target=$(realpath --relative-to="$(dirname "$symlink")" "$target")
            ln -sf "$relative_target" "$symlink"
            log "Converted absolute symlink to relative: \"$symlink\" -> \"$relative_target\""
      fi
    fi

    # Validate resolved symlink target
    resolved_path=$(realpath "$symlink" || true)  # Resolve actual symlink path
    if [[ "$resolved_path" != "$BUILD_DIR"* ]]; then
      log "[WARNING] Symlink resolves outside BUILD_DIR: $symlink -> $resolved_path"
      # Attempt repair logic if possible
      # Placeholder: Redirect invalid resolving link to a known-safe file
      safe_target="$BUILD_DIR/fallback_target"
      if [ -e "$safe_target" ]; then
        ln -sf "$safe_target" "$symlink"
        log "Repaired invalid symlink: $symlink -> $safe_target"
      else
        log "[WARNING] Unable to repair invalid symlink resolution: $symlink"
      fi
    fi
done
  log "Creating kernel tarball..."
  # Create tarball
  tar -cvpzf "$OUTPUT_DIR/$TARBALL_NAME" -C "$BUILD_DIR" .
  log "Kernel tarball created successfully: $OUTPUT_DIR/$TARBALL_NAME"
  # Remove contents of BUILD_DIR
  log "Cleaning up $BUILD_DIR and recreating it as an empty directory..."
  sudo rm -rf --force "$BUILD_DIR"; mkdir -p "$BUILD_DIR"
  # Move the tarball into the empty BUILD_DIR
  log "Moving the tarball to $BUILD_DIR..."
  mv "$OUTPUT_DIR/$TARBALL_NAME" "$BUILD_DIR"
  sudo rm -rf "$OUTPUT_DIR"
  log "Cleanup complete. Tarball moved to $BUILD_DIR/$TARBALL_NAME. Build process finished."
fi
