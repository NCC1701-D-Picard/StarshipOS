#!/bin/bash

# Check if figlet is installed
if ! command -v figlet &> /dev/null
then
    echo "figlet could not be found. Please install figlet."
    exit 1
fi

# Check if module name is provided
if [ -z "$1" ]
then
    echo "Usage: $0 <module-name>"
    exit 1
fi

# Generate ASCII Art Header
figlet "$1"

# Additional header information
cat << 'EOF'

############################################################
#                                                          #
# This script builds the specified module by creating the  #
# necessary build directories and files.                   #
#                                                          #
############################################################

EOF
