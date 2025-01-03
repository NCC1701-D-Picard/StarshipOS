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
HDD_SIZE="40G"
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

function setup_1() {
log "Step 1: Create QCOW2 image"
mkdir -p "$BUILD_DIR"
if [ ! -f "$BUILD_DIR/$HDD_FILENAME" ]; then
  log "Creating QCOW2 disk image ($HDD_FILENAME) of size $HDD_SIZE."
  qemu-img create -f qcow2 "$BUILD_DIR/$HDD_FILENAME" "$HDD_SIZE"
  [ $? -eq 0 ] && echo "Working ..." || { log "ERROR: $HDD_FILENAME not created"; exit 1; }
fi
# Convert QCOW2 to raw for block device compatibility
RAW_FILE="$BUILD_DIR/starship-os.raw"
qemu-img convert -f qcow2 -O raw "$BUILD_DIR/$HDD_FILENAME" "$RAW_FILE"
[ $? -eq 0 ] && echo "Working ..." || { log "ERROR: $RAW_FILE not created"; exit 1; }
# Attach raw image to a loopback device
LOOP_DEVICE=$(sudo losetup --find --show --partscan "$RAW_FILE")
}

function setup_2() {
  log "Step 2: Partition the disk (including BIOS Boot Partition)"
  sudo parted -s "$LOOP_DEVICE" mklabel gpt
  log "Partition Table Creation"
  [ $? -eq 0 ] && echo "Working ..." || { log "ERROR: parted -s $LOOP_DEVICE mklabel gpt"; exit 1; }

  log "Create BIOS boot partition"
  sudo parted -s "$LOOP_DEVICE" mkpart primary 1MiB 2MiB     # BIOS Boot Partition
  [ $? -eq 0 ] && echo "Working ..." || { log "ERROR: parted -s $LOOP_DEVICE mkpart primary 1MiB 2MiB"; exit 1; }

  log "Mark BIOS partition as BIOS boot"
  sudo parted -s "$LOOP_DEVICE" set 1 bios_grub on          # Mark as BIOS Boot
  [ $? -eq 0 ] && echo "Working ..." || { log "ERROR: parted -s $LOOP_DEVICE set 1 bios_grub on"; exit 1; }

  log "Create Linux / (root) partition"
  sudo parted -s "$LOOP_DEVICE" mkpart primary ext4 1024MiB 100% # Root Partition
  [ $? -eq 0 ] && echo "Working ..." || { log "ERROR: not created"; exit 1; }

  sudo partprobe "$LOOP_DEVICE"
  [ $? -eq 0 ] && echo "Working ..." || { log "ERROR: $LOOP_DEVICE not available"; exit 1; }
}

function setup_3() {
  log "Step 3: Format the boot and root partitions"
  log "Formatting ${LOOP_DEVICE}p2"
  sudo mkfs.ext4 "${LOOP_DEVICE}p2"
  log "Retrieve UUID of root partition"
  # shellcheck disable=SC2155
  export ROOT_UUID=$(sudo blkid -s UUID -o value "${LOOP_DEVICE}p2")
  [ $? -eq 0 ] && log "Root UUID is $ROOT_UUID" || { log "ERROR: Failed to retrieve UUID"; exit 1; }
  echo "${LOOP_DEVICE}p2: $ROOT_UUID"
}

function setup_4() {
  log "Step 4: Mount the partitions"
  log "Create mountpoint directories for $ROOT_FILESYSTEM_MOUNTPOINT"
  mkdir -p "$ROOT_FILESYSTEM_MOUNTPOINT"
  [ $? -eq 0 ] && echo "Working ..." || { log "ERROR: in mkdir -p $ROOT_FILESYSTEM_MOUNTPOINT"; exit 1; }
  log "Mount $ROOT_FILESYSTEM_MOUNTPOINT"
  sudo mount "${LOOP_DEVICE}p2" "$ROOT_FILESYSTEM_MOUNTPOINT"
  [ $? -eq 0 ] && echo "Working ..." || { log "ERROR: mounting $ROOT_FILESYSTEM_MOUNTPOINT"; cleanup; }
}

function setup_5() {
  log "Step 5: Ensure the required directories for the bootloader exist"
  log "mkdir -p $ROOT_FILESYSTEM_MOUNTPOINT/boot/grub"
  sudo mkdir -p "$ROOT_FILESYSTEM_MOUNTPOINT/boot/grub"
  [ $? -eq 0 ] && echo "Working ..." || { log "ERROR: mkdir -p /boot/grub"; cleanup; }
}

function create_init_script() {
  sudo cp -p "src/init" "$ROOT_FILESYSTEM_MOUNTPOINT/init"

  sudo chmod +x "$ROOT_FILESYSTEM_MOUNTPOINT/init"
  sudo chown root:root "$ROOT_FILESYSTEM_MOUNTPOINT/init"
}

function copy_to_boot() {
  sudo cp -p "target/kernel/build/kernel/boot/starship" "$ROOT_FILESYSTEM_MOUNTPOINT/boot/starship"
  [ $? -eq 0 ] && echo "Working ..." || { log "ERROR: copying the kernel to /boot/starship"; cleanup; }
  sudo rm -rf "build/kernel/lib/modules/6.12.0/build" # <- Unneeded build artifact.
  log "Copy kernel modules to the boot partition"
  sudo cp -rp "./target/kernel/build/kernel/lib" "$ROOT_FILESYSTEM_MOUNTPOINT/lib"
  [ $? -eq 0 ] && echo "Working ..." || { log "ERROR: copying the kernel modules to /boot/lib"; cleanup; }
  mkdir -p "$ROOT_FILESYSTEM_MOUNTPOINT/boot/grub"
  sudo cp "src/grub.cfg" "$ROOT_FILESYSTEM_MOUNTPOINT/boot/grub/grub.cfg"
#  sed -i "s|root=[^ ]*|root=UUID=$ROOT_UUID|g" "$ROOT_FILESYSTEM_MOUNTPOINT/boot/grub/grub.cfg"
}

function install_grub() {
  # Install GRUB on the device
  log "Installing GRUB..."
  sudo grub-install --target=i386-pc --boot-directory="$ROOT_FILESYSTEM_MOUNTPOINT/boot" "$LOOP_DEVICE"
  [ $? -eq 0 ] && echo "Working ..." || { log "ERROR: installing GRUB"; cleanup; }
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

function copy_to_root() {
  create_filesystem

# Add sSome linux tools & GLIBC
  local qcow2Home=$(pwd)
  sudo cp -pv "target/gnu-tools-glibc/build/unified-rootfs.tar.gz" "$ROOT_FILESYSTEM_MOUNTPOINT"
  cd "$ROOT_FILESYSTEM_MOUNTPOINT"
  sudo tar xvf "unified-rootfs.tar.gz"
  sudo rm "unified-rootfs.tar.gz"
  cd "$qcow2Home"
# OpenJDK23 @ /java
  sudo cp -rp "target/java/build/jdk" "$ROOT_FILESYSTEM_MOUNTPOINT/java"; [ $? -eq 0 ] && echo "Working ..." || { log "ERROR"; cleanup; }

# Install the init system
  log "Installing Init system"
  sudo mkdir -p "$ROOT_FILESYSTEM_MOUNTPOINT/var/lib/starship"
  sudo cp "target/init/target/init-0.1.0-SNAPSHOT.jar" "$ROOT_FILESYSTEM_MOUNTPOINT/var/lib/starship/init.jar"
  sudo ln -s "$ROOT_FILESYSTEM_MOUNTPOINT/var/lib/starship/init.jar" "$ROOT_FILESYSTEM_MOUNTPOINT/sbin/init"
  sudo cp "target/init-bundle-manager/target/init-bundle-manager-0.1.0-SNAPSHOT.jar" "$ROOT_FILESYSTEM_MOUNTPOINT/var/lib/starship/bundle-manager.jar"
  create_init_script
}

function teardown_1() {
  sudo chown -R root:root "$ROOT_FILESYSTEM_MOUNTPOINT"
  sudo chmod -R 755 "$ROOT_FILESYSTEM_MOUNTPOINT"

  # Step 7: Unmount and detach
  log "Unmounting partitions and detaching loop device."
  sudo umount "$ROOT_FILESYSTEM_MOUNTPOINT"; [ $? -eq 0 ] && echo "Working ..." || { log "ERROR: unmounting $ROOT_FILESYSTEM_MOUNTPOINT"; cleanup; }
  sudo losetup -d "$LOOP_DEVICE"; [ $? -eq 0 ] && echo "Working ..." || { log "ERROR: disconnecting $LOOP_DEVICE"; cleanup; }
}

function teardown_2() {
  # Recreate the QCOW2 file after modifications
  log "Recreate the QCOW2 file after modifications"
  qemu-img convert -f raw -O qcow2 "$RAW_FILE" "$BUILD_DIR/$HDD_FILENAME"
  [ $? -eq 0 ] && echo "Working ..." || { log "ERROR: recreating the QCOW2 file after modifications"; EXIT 1; }
  rm -f "$RAW_FILE"
  [ $? -eq 0 ] && echo "Working ..." || { log "ERROR"; EXIT 1; }
}

if [ ! -d build ]; then

  # Create disk image file. loopback device.
  setup_1
  # partition the image, (hd0,gpt1), (hd0,gpt2)
  setup_2
  # Format partitions.
  setup_3
  # Create /boot/grub
  setup_4
  # Mount partition.
  setup_5

  # Copy kernel to device
  copy_to_boot

  # Install GRUB.
  install_grub

  # Populate the drive
  copy_to_root

  # Write the Init Script
  create_init_script
pause
#  create_symlink "/lib/x86_64-linux-gnu/librt-2.31.so" "/lib/x86_64-linux-gnu/librt.so.1"
#  create_symlink "/lib/x86_64-linux-gnu/libm.so" "/lib/x86_64-linux-gnu/libm.so.6"

  # Unmount the filesystem
  teardown_1
  # Shutdown loopback device.
  teardown_2
else
  log "Nothing to do"
fi
cat "../module.log" >> "../../build.log"
log "Disk setup with bootloader and root filesystem completed successfully."
