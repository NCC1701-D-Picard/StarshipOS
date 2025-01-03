#!/bin/bash

# Exit on errors and unset variables
set -e
set -u

clear

# Default values for parameters
PROJECT_DIR="${PROJECT_DIR:-$HOME/PROJECTS/StarshipOS}"
DISK_IMAGE_PATH="${DISK_IMAGE_PATH:-$PROJECT_DIR/qcow2_image/build/starship-os.qcow2}"
LOG_PATH="${LOG_PATH:-$PROJECT_DIR/starship-boot.log}"
MEMORY="${MEMORY:-2048}"  # Default RAM size in MB
CPU="${CPU:-qemu64}"      # Default CPU type
SMP="${SMP:-1}"           # Default number of virtual processors
ENABLE_KVM="${ENABLE_KVM:-1}" # Enable KVM by default (if supported)

# Help/usage message function
usage() {
    cat <<EOF
Usage: $(basename "$0") [options]

This script runs a QEMU VM using the specified QCOW2 disk image, with customizable memory, CPU, and logging options.

Options:
  --disk PATH       Path to QCOW2 disk image (default: $DISK_IMAGE_PATH)
  --log PATH        Path to log file (default: $LOG_PATH)
  --memory MB       RAM size in MB (default: $MEMORY)
  --cpu TYPE        CPU type (default: $CPU)
  --smp N           Number of virtual CPUs (default: $SMP)
  --no-kvm          Disable KVM acceleration (enabled by default if supported)
  --help            Show this help message and exit

Examples:
  $(basename "$0")                        Run with default settings
  $(basename "$0") --memory 4096          Allocate 4GB RAM to the VM
  $(basename "$0") --disk /path/to/image.qcow2 --log /path/to/log.log --smp 4

EOF
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --disk)
            DISK_IMAGE_PATH="$2"
            shift 2
            ;;
        --log)
            LOG_PATH="$2"
            shift 2
            ;;
        --memory)
            MEMORY="$2"
            shift 2
            ;;
        --cpu)
            CPU="$2"
            shift 2
            ;;
        --smp)
            SMP="$2"
            shift 2
            ;;
        --no-kvm)
            ENABLE_KVM=0
            shift
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Ensure that QEMU is installed
if ! command -v qemu-system-x86_64 &> /dev/null; then
    echo "Error: QEMU is not installed or not in your PATH."
    exit 1
fi

# Ensure the disk image exists
if [[ ! -f "$DISK_IMAGE_PATH" ]]; then
    echo "Error: Disk image not found at $DISK_IMAGE_PATH"
    exit 1
fi

# Enable logging with timestamps
exec > >(while IFS= read -r line; do echo "[$(date +'%Y-%m-%d %H:%M:%S')] $line"; done | tee -a "$LOG_PATH") 2>&1

# Determine if KVM is supported and enabled
KVM_ARG=""
if [[ $ENABLE_KVM -eq 1 && -x /dev/kvm ]]; then
    KVM_ARG="-enable-kvm"
    echo "KVM acceleration is enabled."
else
    echo "KVM acceleration is disabled or not supported by your hardware."
fi

# Start the QEMU virtual machine
echo "Starting QEMU virtual machine with the following settings:"
echo "  Disk Image Path: $DISK_IMAGE_PATH"
echo "  Log Path: $LOG_PATH"
echo "  Memory: ${MEMORY} MB"
echo "  CPU Type: $CPU"
echo "  Virtual CPUs (SMP): $SMP"

qemu-system-x86_64 \
  -boot c \
  -hda "$DISK_IMAGE_PATH" \
  -m "$MEMORY" \
  -cpu "$CPU" \
  -smp "$SMP" \
  -net nic -net user \
  -serial stdio \
  -object memory-backend-ram,id=ram1,size="${MEMORY}M" \
  -numa node,memdev=ram1 \
  -d cpu_reset,guest_errors \
  -mem-path /dev/hugepages \
  $KVM_ARG
