#!/bin/bash

#
# Copyright (c) 2025.
#

cd "kernel/starship_kernel"
make mrproper
make defconfig
cd "../../"

