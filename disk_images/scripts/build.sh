#!/bin/bash
#
# Copyright (c) 2024.
#

# shellcheck disable=SC2015

# Exit on errors or unset variables
set -e
set -u

# Directories and configuration
BUILD_DIR="build"
HDD_FILENAME="starship-os.qcow2"
HDD_SIZE="5G"

KERNEL="NCC1701-D"
KERNEL_PATH="target/kernel/build/boot/$KERNEL"
KERNEL_MODS="target/kernel/build/lib"
GNU_TOOLS="target/gnu-tools-glibc/build/unified-system.tar.gz"
INIT="target/init/target/init-0.1.0-SNAPSHOT.jar"
BUNDLE_MGR="target/init-bundle-manager/target/init-bundle-manager-0.1.0-SNAPSHOT.jar"

export ROOT_FILESYSTEM_MOUNTPOINT="$BUILD_DIR/rootfs"

# Cleanup function
cleanup() {
    sudo umount "$ROOT_FILESYSTEM_MOUNTPOINT" &>/dev/null || true
    [[ -n "${LOOP_DEVICE:-}" ]] && sudo losetup -d "$LOOP_DEVICE" &>/dev/null || true
    rm -rf "$ROOT_FILESYSTEM_MOUNTPOINT"
}
trap cleanup EXIT

function log() {
    echo "[qcow2_image: $(date +'%Y-%m-%d %H:%M:%S')] $1"
}

function pause() {
  echo "Paused, press [ENTER] to continue..."
  # shellcheck disable=SC2162
  read -p "x"
}

function create_filesystem() {
  log "Step 6: Create the root filesystem"
  sudo mkdir -p "$ROOT_FILESYSTEM_MOUNTPOINT/bin"; [ $? -eq 0 ] && echo "Working ..." || { log "ERROR"; cleanup; }
  sudo mkdir -p "$ROOT_FILESYSTEM_MOUNTPOINT/dev"; [ $? -eq 0 ] && echo "Working ..." || { log "ERROR"; cleanup; }
  sudo mkdir -p "$ROOT_FILESYSTEM_MOUNTPOINT/etc"; [ $? -eq 0 ] && echo "Working ..." || { log "ERROR"; cleanup; }
  sudo mkdir -p "$ROOT_FILESYSTEM_MOUNTPOINT/home"; [ $? -eq 0 ] && echo "Working ..." || { log "ERROR"; cleanup; }
  sudo mkdir -p "$ROOT_FILESYSTEM_MOUNTPOINT/lib"; [ $? -eq 0 ] && echo "Working ..." || { log "ERROR"; cleanup; }
  sudo mkdir -p "$ROOT_FILESYSTEM_MOUNTPOINT/lib64"; [ $? -eq 0 ] && echo "Working ..." || { log "ERROR"; cleanup; }
  sudo mkdir -p "$ROOT_FILESYSTEM_MOUNTPOINT/mnt"; [ $? -eq 0 ] && echo "Working ..." || { log "ERROR"; cleanup; }
  sudo mkdir -p "$ROOT_FILESYSTEM_MOUNTPOINT/opt"; [ $? -eq 0 ] && echo "Working ..." || { log "ERROR"; cleanup; }
  sudo mkdir -p "$ROOT_FILESYSTEM_MOUNTPOINT/proc"; [ $? -eq 0 ] && echo "Working ..." || { log "ERROR"; cleanup; }
  sudo mkdir -p "$ROOT_FILESYSTEM_MOUNTPOINT/root"; [ $? -eq 0 ] && echo "Working ..." || { log "ERROR"; cleanup; }
  sudo mkdir -p "$ROOT_FILESYSTEM_MOUNTPOINT/sbin"; [ $? -eq 0 ] && echo "Working ..." || { log "ERROR"; cleanup; }
  sudo mkdir -p "$ROOT_FILESYSTEM_MOUNTPOINT/sys"; [ $? -eq 0 ] && echo "Working ..." || { log "ERROR"; cleanup; }
  sudo mkdir -p "$ROOT_FILESYSTEM_MOUNTPOINT/tmp"; [ $? -eq 0 ] && echo "Working ..." || { log "ERROR"; cleanup; }
  sudo mkdir -p "$ROOT_FILESYSTEM_MOUNTPOINT/usr/bin"; [ $? -eq 0 ] && echo "Working ..." || { log "ERROR"; cleanup; }
  sudo mkdir -p "$ROOT_FILESYSTEM_MOUNTPOINT/usr/lib"; [ $? -eq 0 ] && echo "Working ..." || { log "ERROR"; cleanup; }
  sudo mkdir -p "$ROOT_FILESYSTEM_MOUNTPOINT/usr/lib64"; [ $? -eq 0 ] && echo "Working ..." || { log "ERROR"; cleanup; }
  sudo mkdir -p "$ROOT_FILESYSTEM_MOUNTPOINT/usr/sbin"; [ $? -eq 0 ] && echo "Working ..." || { log "ERROR"; cleanup; }
  sudo mkdir -p "$ROOT_FILESYSTEM_MOUNTPOINT/var/log"; [ $? -eq 0 ] && echo "Working ..." || { log "ERROR"; cleanup; }
  sudo mkdir -p "$ROOT_FILESYSTEM_MOUNTPOINT/var/tmp"; [ $? -eq 0 ] && echo "Working ..." || { log "ERROR"; cleanup; }
  sudo mkdir -p "$ROOT_FILESYSTEM_MOUNTPOINT/var/run"; [ $? -eq 0 ] && echo "Working ..." || { log "ERROR"; cleanup; }
}

function setup() {
  log "Create QCOW2 image ..."

  mkdir -p "$BUILD_DIR"
  if [ ! -f "$BUILD_DIR/$HDD_FILENAME" ]; then
    log "Creating QCOW2 disk image ($HDD_FILENAME) of size $HDD_SIZE."
    qemu-img create -f qcow2 "$BUILD_DIR/$HDD_FILENAME" "$HDD_SIZE"
  fi

  RAW_FILE="$BUILD_DIR/starship-os.raw"
  qemu-img convert -f qcow2 -O raw "$BUILD_DIR/$HDD_FILENAME" "$RAW_FILE"

  # shellcheck disable=SC2016
  export LOOP_DEVICE=$(sudo losetup --find --show --partscan "$RAW_FILE")
  log "Create mountpoint directories for $ROOT_FILESYSTEM_MOUNTPOINT"
  mkdir -p "$ROOT_FILESYSTEM_MOUNTPOINT"

  log "Mount $ROOT_FILESYSTEM_MOUNTPOINT"
  sudo mount "${LOOP_DEVICE}p2" "$ROOT_FILESYSTEM_MOUNTPOINT"
  log "Partition the disk (including BIOS Boot Partition)"
  sudo parted -s "$LOOP_DEVICE" mklabel gpt
  log "Partition Table Creation"

  log "Create BIOS boot partition"
  sudo parted -s "$LOOP_DEVICE" mkpart primary 1MiB 2MiB     # BIOS Boot Partition

  log "Mark BIOS partition as BIOS boot"
  sudo parted -s "$LOOP_DEVICE" set 1 bios_grub on          # Mark as BIOS Boot

  log "Create Linux / (root) partition"
  sudo parted -s "$LOOP_DEVICE" mkpart primary ext4 1024MiB 100% # Root Partition
  sudo partprobe "$LOOP_DEVICE"
  log "Format the boot and root partitions"
  log "Formatting ${LOOP_DEVICE}p2"
  sudo mkfs.ext4 "${LOOP_DEVICE}p2"
  log "Retrieve UUID of root partition"
  # shellcheck disable=SC2016
  export ROOT_UUID=$(sudo blkid -s UUID -o value "${LOOP_DEVICE}p2")
  echo "${LOOP_DEVICE}p2: $ROOT_UUID"
  log "Ensure the required directories for the bootloader exist"
  log "mkdir -p $ROOT_FILESYSTEM_MOUNTPOINT/boot/grub"
  sudo mkdir -p "$ROOT_FILESYSTEM_MOUNTPOINT/boot/grub"
  create_filesystem
}

function create_init_script() {
  sudo cp -p "src/init" "$ROOT_FILESYSTEM_MOUNTPOINT/init"

  sudo chmod +x "$ROOT_FILESYSTEM_MOUNTPOINT/init"
  sudo chown root:root "$ROOT_FILESYSTEM_MOUNTPOINT/init"
}

function install_kernel() {
  log "Copy Linux kernel NCC1701-D to the boot partition."
  sudo cp -pv "$KERNEL_PATH" "$ROOT_FILESYSTEM_MOUNTPOINT/boot/$KERNEL"; [ $? -eq 0 ] && echo "Working ..." || { log "ERROR: copying the kernel to /boot/$KERNEL"; cleanup; }
  sudo rm -rf "build/kernel/lib/modules/6.12.0/build" # <- Unneeded build artifact.
  log "Copy Linux kernel modules to the boot partition."
  sudo cp -rpv "$KERNEL_MODS" "$ROOT_FILESYSTEM_MOUNTPOINT"; [ $? -eq 0 ] && echo "Working ..." || { log "ERROR: copying the kernel modules to /boot/lib"; cleanup; }

#  TODO We're going to have to handle building multiple grub.cfg depending on to be determined parameters.
  mkdir -p "$ROOT_FILESYSTEM_MOUNTPOINT/boot/grub"
  sudo cp -v "src/grub.cfg" "$ROOT_FILESYSTEM_MOUNTPOINT/boot/grub/grub.cfg"
  log "Installing GRUB..."
  sudo grub-install --target=i386-pc --boot-directory="$ROOT_FILESYSTEM_MOUNTPOINT/boot" "$LOOP_DEVICE"; [ $? -eq 0 ] && echo "Working ..." || { log "ERROR: installing GRUB"; cleanup; }
}


function create_symlink() {
    local target="$1"
    local link_name="$2"
    if [ -e "$ROOT_FILESYSTEM_MOUNTPOINT/$link_name" ]; then
        log "Symlink already exists: $link_name -> $(readlink -f "$ROOT_FILESYSTEM_MOUNTPOINT/$link_name")"
    else
        sudo ln -sv "$target" "$ROOT_FILESYSTEM_MOUNTPOINT/$link_name"
        log "Created symlink: $link_name -> $target"
    fi
}

function install_system() {
pause
  # Add some linux tools & GLIBC
  local qcow2Home="$(pwd)"
pause
  tar xvzf "$(pwd)/target/gnu-tools-glibc/build/unified-system.tar.gz" -C "target/"
pause
  log "Installing glibc"


  log "Installing Java OpenJDK (23)"
  sudo cp -rpv "target/java/build/jdk" "$ROOT_FILESYSTEM_MOUNTPOINT/java"; [ $? -eq 0 ] && echo "Working ..." || { log "ERROR"; cleanup; }

  # Install the JVM (Init.groovy) init system
  log "Installing the JVM Init system."
  sudo mkdir -p "$ROOT_FILESYSTEM_MOUNTPOINT/var/lib/$KERNEL"
  sudo cp -pv "$INIT" "$ROOT_FILESYSTEM_MOUNTPOINT/var/lib/$KERNEL/init.jar"
  sudo ln -sv "$ROOT_FILESYSTEM_MOUNTPOINT/var/lib/$KERNEL/init.jar" "$ROOT_FILESYSTEM_MOUNTPOINT/sbin/init"
  sudo cp -pv "$BUNDLE_MGR" "$ROOT_FILESYSTEM_MOUNTPOINT/var/lib/$KERNEL/bundle-manager.jar"
  sudo ln -sv "$ROOT_FILESYSTEM_MOUNTPOINT/var/lib/$KERNEL/bundle-manager.jar" "$ROOT_FILESYSTEM_MOUNTPOINT/sbin/bundle-manager"
  create_init_script
}

function teardown() {
  sudo chown -R root:root "$ROOT_FILESYSTEM_MOUNTPOINT"
  sudo chmod -R 755 "$ROOT_FILESYSTEM_MOUNTPOINT"

  # Step 7: Unmount and detach
  log "Unmounting partitions and detaching loop device."
  sudo umount "$ROOT_FILESYSTEM_MOUNTPOINT"; [ $? -eq 0 ] && echo "Working ..." || { log "ERROR: unmounting $ROOT_FILESYSTEM_MOUNTPOINT"; cleanup; }
  sudo losetup -d "$LOOP_DEVICE"; [ $? -eq 0 ] && echo "Working ..." || { log "ERROR: disconnecting $LOOP_DEVICE"; cleanup; }
  # Recreate the QCOW2 file after modifications
  log "Recreate the QCOW2 file after modifications"
  qemu-img convert -f raw -O qcow2 "$RAW_FILE" "$BUILD_DIR/$HDD_FILENAME"
  [ $? -eq 0 ] && echo "Working ..." || { log "ERROR: recreating the QCOW2 file after modifications"; EXIT 1; }
  rm -f "$RAW_FILE"
  [ $? -eq 0 ] && echo "Working ..." || { log "ERROR"; EXIT 1; }
}

if [ ! -d build ]; then

  # Create disk image file. loopback device.
  setup

  # Copy kernel to device
  install_kernel

  # Populate the drive
  install_system

  # Write the Init Script
  create_init_script

#  create_symlink "/lib/x86_64-linux-gnu/librt-2.31.so" "/lib/x86_64-linux-gnu/librt.so.1"
#  create_symlink "/lib/x86_64-linux-gnu/libm.so" "/lib/x86_64-linux-gnu/libm.so.6"

  # Unmount the filesystem
  teardown
else
  log "Nothing to do"
fi
cat "../module.log" >> "../../build.log"
log "Disk setup with bootloader and root filesystem completed successfully."
