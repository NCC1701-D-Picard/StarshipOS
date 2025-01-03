#!/bin/bash
# shellcheck disable=SC2164
# shellcheck disable=SC2162
# shellcheck disable=SC2046

set -e  # Exit immediately if a command exits with a non-zero status
set -u  # Treat unset variables as an error

# Define variables
CURRENT_DIR="$(pwd)"
CONFIGURATION="linux-x86_64-server-release"
BUILD_DIR="build"
JDK_ARCHIVE_URL="https://download.java.net/java/GA/jdk23.0.1/c28985cbf10d4e648e4004050f8781aa/11/GPL/openjdk-23.0.1_linux-x64_bin.tar.gz"
JDK_ARCHIVE_NAME="openjdk-23.0.1_linux-x64_bin.tar.gz"
JDK_DIR="jdk"

# These 4 vars unfortunately need to be abs. paths.
BOOT_JDK="$(pwd)/jdk-23.0.1"
PREFIX_DIR="$(pwd)/build/bin"
EXEC_PREFIX_DIR="$(pwd)/build/lib"
FINAL_BUILD_DIR="$(pwd)/build"

# Logging function
function log() {
    echo "[java: $(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "../module.log"
}

# Function to download and unpack JDK archive
download_and_unpack_jdk() {
    log "Downloading BOOT JDK archive..."
    wget --progress=bar "$JDK_ARCHIVE_URL" -O "$JDK_ARCHIVE_NAME"
    log "Unpacking BOOT JDK archive..."
    tar -xzf "$JDK_ARCHIVE_NAME"
    rm "$JDK_ARCHIVE_NAME"
}

# Function to configure and build the JDK
configure_and_build_jdk() {
    cd "$JDK_DIR"
    make CONF="${CONFIGURATION}" clean
    log "Configuring build with boot JDK..."
    ./configure --with-boot-jdk="$BOOT_JDK" --with-jvm-variants=server \
    --enable-libffi-bundling --with-jvm-features="compiler1,compiler2,zgc" \
    --prefix="$PREFIX_DIR" \
    --exec-prefix="$EXEC_PREFIX_DIR"

#    log "Cleaning previous builds if any..."
#    make CONF="${CONFIGURATION}" clean
    log "Building JDK..."
    make CONF="${CONFIGURATION}" 2>&1 | tee -a ../build.log
    make CONF="${CONFIGURATION}" docs 2>&1 | tee -a ../build.log
    cd "$CURRENT_DIR"
}

# Main script logic
log "Starting JDK build script."

if [ ! -d "$BUILD_DIR" ]; then
    download_and_unpack_jdk
    configure_and_build_jdk

    mkdir -p "${FINAL_BUILD_DIR}"
    log "Copying final JDK build to ${FINAL_BUILD_DIR}..."
    cp -rv "$CURRENT_DIR/jdk/build/linux-x86_64-server-release/jdk" "$FINAL_BUILD_DIR"

    log "Removing BOOT_JDK directory..."
    rm -rf "$BOOT_JDK"
else
    log "Nothing to do."
fi
#sudo chown -RL --dereference $(whoami):$(whoami) "build/jdk" 2>&1
cat "../module.log" >> "../../build.log"
log "Build java JDK complete."
