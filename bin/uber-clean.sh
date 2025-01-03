#!/bin/bash
clear

echo "*****************************************************************************"
echo "* This project requires sudo to build. Sorry, if you are not a suduer, Ask! *"
echo "*****************************************************************************"

# Native
sudo rm -rfv "./kernel/build" "./kernel/target"
sudo rm -rfv "./java/build" "./java/target"
sudo rm -rfv "./gnu-tool/build" "./gnu-tool/target"

# JVM
sudo rm -rfv "./system-bridge/build" "./system-bridge/target"
sudo rm -rfv "./userland-java/build" "./userland-java/target"
sudo rm -rfv "./starship-sdk/build" "./starship-sdk/target"

# Glue
sudo rm -rfv "./grub/build" "./grub/target"
sudo rm -rfv "./initramfs/build" "./initramfs/target"
sudo rm -rfv "./qcow2_image/build" "./qcow2_image/target"

# Deep clean especially Native
sudo mvn clean
