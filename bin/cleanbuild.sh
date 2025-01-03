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

# Exit on errors and unset variables
set -e
set -u

clear

# Default variables
UBER_CLEAN=0
DEBUG=0
LOG_FILE="build.log"
MODULE_PATHS=( "userland-java" "kernel" "gnu-tools-glibc" "init" "qcow2_image" "init-bundle-manager" "java" "starship-sdk") # "grub" "initramfs"
ALWAYS_REBUILD=( "qcow2_image" )  # These are always rebuilt, directories always removed "grub" "initramfs"

# Help/usage function
usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

This script automates the build process for a multi-module Maven project. Modules are included
in the build process based on the presence of a "build" directory in each module, except certain
modules (grub, initramfs, qcow2_image), which are always cleaned and rebuilt.

Options:
  -h, --help             Show this help message and exit
  -l, --logfile FILE     Specify a log file (default: build.log)
  --uber-clean           Remove the "build" directories for all modules and force a full rebuild
  --debug                Set breakpoints at logging time and run mvn -X targets.
  --clean MODULE         Remove the "build" directory for a specific module (forces rebuild during next build)
  --force MODULE         Remove the "build" directory and rebuild only the specified module immediately

Notes:
  - Grub, Initramfs, and Qcow2 modules are always cleaned and rebuilt.
  - The Maven root reactor will skip rebuilding other modules whose "build" directories exist,
    unless you clean them manually or use --uber-clean.

Examples:
  $(basename "$0")                  Standard build (grub, initramfs, and qcow2 always rebuilt)
  $(basename "$0") --uber-clean     Force a complete reset and rebuild all modules
  $(basename "$0") --clean kernel   Remove kernel "build" directory and include it in the next build
EOF
}

# Cleanup function for a specific module
clean_module() {
    local module=$1
    local path="$module/build"
    local target="$module/target"
    if [[ -d "$path" ]]; then
        echo "Cleaning $module (removing $path directory& $target directory)..."
        sudo rm -rf --force "$path" "$target"
    else
        echo "No build directory found for $module; nothing to clean."
    fi
}

# Uber-clean function - cleans all modules including always-rebuilt ones
uber_clean_modules() {
    echo "Performing --uber-clean: Cleaning all module build directories..."
    for module in "${MODULE_PATHS[@]}"; do
        clean_module "$module"
    done
}

# Always clean the "always rebuilt" modules
clean_always_rebuilt_modules() {
    echo "Cleaning always-rebuilt modules (grub, initramfs, and qcow2_image)..."
    for module in "${ALWAYS_REBUILD[@]}"; do
        clean_module "$module"
    done
}

# Parse command-line options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        -l|--logfile)
            LOG_FILE="$2"
            shift 2
            ;;
        --uber-clean)
            UBER_CLEAN=1
            shift
            ;;
        --debug)
            DEBUG=1
            shift
            ;;
        --clean)
            CLEAN_MODULE="$2"
            if [[ ! " ${MODULE_PATHS[*]} " =~ $CLEAN_MODULE ]]; then
                echo "Error: Unknown module - $CLEAN_MODULE. Valid modules: ${MODULE_PATHS[*]}"
                exit 1
            fi
            clean_module "$CLEAN_MODULE"
            shift 2
            ;;
        --force)
            FORCE_MODULE="$2"
            if [[ ! " ${MODULE_PATHS[*]} " =~ $FORCE_MODULE ]]; then
                echo "Error: Unknown module - $FORCE_MODULE. Valid modules: ${MODULE_PATHS[*]}"
                exit 1
            fi
            echo "Forcing rebuild of $FORCE_MODULE only..."
            clean_module "$FORCE_MODULE"
            MAVEN_FORCE_COMMAND="mvn clean install -pl $FORCE_MODULE"
            eval "$MAVEN_FORCE_COMMAND" 2>&1 | tee -a "$LOG_FILE"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# If --uber-clean is requested, clean every module directory
if [[ $UBER_CLEAN -eq 1 ]]; then
    uber_clean_modules
else
    # Always clean modules in the ALWAYS_REBUILD list, no matter what
    clean_always_rebuilt_modules
fi

# Start the root reactor build with Maven
echo "*****************************************************************************"
echo "*                              Starting StarshipOS Build                      *"
echo "*****************************************************************************"

echo "Executing Maven build from the root reactor..."

if [[ $DEBUG -eq 1 ]]; then
  mvn clean -X install 2>&1 | tee "$LOG_FILE"
else
  mvn clean install 2>&1 | tee "$LOG_FILE"
fi

# Logger
function log() {
    echo "[DEBUG: starship-os: $(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "../module.log"
    if [[ $DEBUG -eq 1 ]]; then
      echo "Paused DEBUG BREAKPOINT: [ENTER] to continue."
      read -p "x"
    fi
}

echo "*****************************************************************************"
echo "*                              Build Complete                               *"
echo "*****************************************************************************"
