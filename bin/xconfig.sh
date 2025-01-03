#!/bin/bash
clear

echo "*****************************************************************************"
echo "* This project requires sudo to build. Sorry, if you are not a suduer, Ask! *"
echo "*****************************************************************************"

set -e  # Exit immediately if a command exits with a non-zero status
set -u  # Treat unset variables as an error

HOME=$PWD
KERNEL_ROOT=$PWD/kernel/linux

cd "$KERNEL_ROOT"
sudo make clean
make xconfig
cp "$KERNEL_ROOT/.config" "$HOME/.config"
cd "$HOME"
