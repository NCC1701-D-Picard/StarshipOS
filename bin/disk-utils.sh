#!/bin/bash

# Attaches a disk image to a loop device
# $1 -> Path to the disk image (e.g., "my-disk.img")
# Outputs the loop device (e.g., "/dev/loop0")
attach_disk() {
    local disk_image="$1"
    local loop_device

    loop_device=$(sudo losetup -fP --show "$disk_image")
    if [[ -z "$loop_device" ]]; then
        echo "[ERROR] Failed to attach disk image: $disk_image"
        exit 1
    fi

    echo "$loop_device"
}

# Creates a disk image of a given size
# $1 -> Path to the disk image (e.g., "my-disk.img")
# $2 -> Size of the disk image (e.g., "1024" for 1GB, in MiB)
create_disk_image() {
    local disk_image="$1"
    local disk_size_mib="$2"

    dd if=/dev/zero of="$disk_image" bs=1M count="$disk_size_mib" status=progress
    if [[ $? -ne 0 ]]; then
        echo "[ERROR] Failed to create disk image: $disk_image"
        exit 1
    fi
    echo "[INFO] Disk image created: $disk_image ($disk_size_mib MiB)"
}

# Partitions a disk image into a single primary partition
# $1 -> Loop device for the disk image (e.g., "/dev/loop0")
# Outputs the partition device (e.g., "/dev/loop0p1")
partition_disk_image() {
    local loop_device="$1"

    # Create a partition table (MBR) and add one primary partition
    echo -e "o\nn\np\n1\n\n\nw" | sudo fdisk "$loop_device"

    # Wait for the new partition to appear
    sudo partprobe "$loop_device"
    sleep 2

    # Find the new partition
    local partition=$(lsblk -lno NAME,TYPE | grep "${loop_device#/dev/}" | awk '/part/ {print "/dev/"$1}')
    if [[ -z "$partition" ]]; then
        echo "[ERROR] Failed to create and detect partition on $loop_device"
        exit 1
    fi

    echo "$partition"
}

# Formats a partition with a given filesystem (e.g., ext4)
# $1 -> Partition device (e.g., "/dev/loop0p1")
# $2 -> Filesystem type (e.g., "ext4")
format_partition() {
    local partition="$1"
    local filesystem="$2"

    sudo mkfs."$filesystem" "$partition"
    if [[ $? -ne 0 ]]; then
        echo "[ERROR] Failed to format partition: $partition as $filesystem"
        exit 1
    fi

    echo "[INFO] Partition $partition formatted as $filesystem"
}

# Mounts a specific partition with a filesystem
# $1 -> The partition device (e.g., "/dev/loop0p1")
# $2 -> The mount point (e.g., "/mnt/disk")
mount_partition() {
    local partition="$1"
    local mount_point="$2"

    if [[ ! -d "$mount_point" ]]; then
        sudo mkdir -p "$mount_point"
    fi

    sudo mount "$partition" "$mount_point"
    if [[ $? -ne 0 ]]; then
        echo "[ERROR] Failed to mount partition: $partition"
        exit 1
    fi

    echo "[INFO] Mounted $partition at $mount_point"
}

# Unmounts a partition
# $1 -> The mount point (e.g., "/mnt/disk")
unmount_partition() {
    local mount_point="$1"

    sudo umount "$mount_point"
    if [[ $? -ne 0 ]]; then
        echo "[ERROR] Failed to unmount $mount_point"
        exit 1
    fi

    echo "[INFO] Unmounted $mount_point"
}

# Detaches a loop device
# $1 -> Loop device (e.g., "/dev/loop0")
detach_disk() {
    local loop_device="$1"

    sudo losetup -d "$loop_device"
    if [[ $? -ne 0 ]]; then
        echo "[ERROR] Failed to detach $loop_device"
        exit 1
    fi

    echo "[INFO] Detached $loop_device"
}

# Helper to get partition information (e.g., which /dev/loopXp1 was created)
# $1 -> The loop device (e.g., "/dev/loop0")
get_partitions() {
    local loop_device="$1"
    lsblk -lno NAME,TYPE | grep "${loop_device#/dev/}" | awk '/part/ {print "/dev/"$1}'
}

# Helper to pause a shell script and drop to a new shell. TODO how about a prompt ;)
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
