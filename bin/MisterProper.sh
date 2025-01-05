#!/usr/bin/bash
cd kernel/linux
make defconfig
make mrproper
make defconfig
exit 0