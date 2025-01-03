#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
set -u  # Treat unset variables as an error


function log() {
  echo "[initramfs: $(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "../build.log"
}

function pause() {
  echo "Press [ENTER] to continue ..."
  read -p "hi"
}

function create_filesystem() {
    log "Creating initrd build directories..."
    mkdir -p "build/initrd/bin"
    mkdir -p "build/initrd/dev"
    mkdir -p "build/initrd/etc"
    mkdir -p "build/initrd/home"
    mkdir -p "build/initrd/lib"
    mkdir -p "build/initrd/lib64"
    mkdir -p "build/initrd/mnt"
    mkdir -p "build/initrd/opt"
    mkdir -p "build/initrd/proc"
    mkdir -p "build/initrd/root"
    mkdir -p "build/initrd/sbin"
    mkdir -p "build/initrd/sys"
    mkdir -p "build/initrd/tmp"
    mkdir -p "build/initrd/usr/bin"
    mkdir -p "build/initrd/usr/lib"
    mkdir -p "build/initrd/usr/lib64"
    mkdir -p "build/initrd/usr/sbin"
    mkdir -p "build/initrd/var/log"
    mkdir -p "build/initrd/var/tmp"
    mkdir -p "build/initrd/var/run"
    mkdir -p "build/initrd/boot"
    mkdir -p "build/initrd/boot/grub"
}

function make_device_nodes() {
  log "Making console and sda nodes..."
  cd "build/initrd/dev"
  sudo mknod sda b 8 0
  sudo mknod console c 5 1
  cd "../../../"  # Return to `module root`
}

function copy_kernel() {
  log "Copying required files..."
  cp -v "target/kernel/build/kernel/boot/starship" "build/initrd/boot/starship"
  cp -rv "target/kernel/build/kernel/lib" "build/initrd"
}

function copy_grub_cfg() {
  cp "target/build/grub/grub-0.1.0-SNAPSHOT/hd0/boot/grub/grub.cfg" "build/initrd/boot/grub/grub.cfg"
}

function copy_gnu-tools() {
  cp -rv "target/gnu-tools/build/gnu-tools/bin" "build/initrd"
  cp -rv "target/gnu-tools/build/gnu-tools/etc" "build/initrd"
  cp -rv "target/gnu-tools/build/gnu-tools/include" "build/initrd"
  cp -rv "target/gnu-tools/build/gnu-tools/lib" "build/initrd"
  cp -rv "target/gnu-tools/build/gnu-tools/sbin" "build/initrd"
  cp -rv "target/gnu-tools/build/gnu-tools/share" "build/initrd" >/dev/null 2>&1
}

function create_init_script() {
  cat << 'EOF' > "build/initrd/init"
#!/bin/busybox sh

# Function for rescue shell in case of critical failures
rescue_shell() {
    echo "An error occurred. Dropping to emergency shell..."
    exec /bin/sh
}

# Mount essential filesystems
echo "Starting StarshipOS..."
mount -t proc proc /proc || rescue_shell
mount -t sysfs sys /sys || rescue_shell
mount -t devtmpfs dev /dev || rescue_shell

# Mount the root filesystem in read-only mode
echo "Mounting root filesystem..."
mount -o ro /dev/sda1 /mnt || rescue_shell

# Prepare for pivot_root
cd /mnt || rescue_shell
mkdir -p old_root
pivot_root . old_root || rescue_shell

# Remove the old initramfs
if [ -d /old_root ]; then
    umount -l /old_root
    rm -rf /old_root
fi

# Start the Groovy Init
exec /usr/bin/java -jar /var/starship/system-bridge.jar
EOF

  sudo chmod +x "build/initrd/init"
  sudo chown root:root "build/initrd/init"
}

function create_initramfs() {
    # Package initrd.gz
    log "Packaging initrd file..."
    sudo tree "build/initrd" -o "before.txt" # tak a rdfs snapshot before
    cd "build/initrd"
    find . -depth -print0 | sudo cpio --null -o --format=newc | gzip -9 > "../initrd.gz"
    cd ../../  # Return to the script's base directory
}

function quality_report() {
    log "Finished building initrd.gz"
    mkdir -p "build/temp"
    zcat "build/initrd.gz" | (cd "build/temp" && sudo cpio -idmv)
    # shellcheck disable=SC2024
    sudo tree "build/temp" > "after.txt"
    if ! diff -u "before.txt" "after.txt" > "diff_report.txt"; then
      log "Difference detected between before.txt and after.txt!"
      echo "Differences:"
      cat "diff_report.txt"
    fi
}

function cleanup_in_isle42() {
  # Remove device nodes in initrd/dev after packaging
  log "Cleaning up device nodes..."
  sudo rm -f "initrd/dev/sda" "initrd/dev/console"
  log "Device nodes removed."
}

if [ ! -d build ]; then

  create_filesystem
  make_device_nodes

  copy_kernel
  copy_gnu-tools
  copy_grub_cfg

  create_init_script
  create_initramfs

  quality_report
  cleanup_in_isle42

  log "Build initramfs complete."
else
  log "Nothing to do, build already exists."
fi
cat "../module.log" >> "../../build.log"
log "Build initramfs complete."
