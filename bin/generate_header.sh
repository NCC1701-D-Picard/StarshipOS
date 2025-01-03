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
# This program is free software: you can redistribute it   #
# and/or modify it under the terms of the GNU General      #
# Public License as published by the Free Software         #
# Foundation, either version 2 of the License, or (at your #
# option) any later version.                               #
#                                                          #
# This program is distributed in the hope that it will be  #
# useful, but WITHOUT ANY WARRANTY; without even the       #
# implied warranty of MERCHANTABILITY or FITNESS FOR A     #
# PARTICULAR PURPOSE.  See the GNU General Public License  #
# for more details.                                        #
#                                                          #
# You should have received a copy of the GNU General       #
# Public License along with this program.  If not, see     #
# <https://www.gnu.org/licenses/>.                         #
#                                                          #
# Copyright (C) ${YEAR} ${USER}                            #
#                                                          #
############################################################

EOF
