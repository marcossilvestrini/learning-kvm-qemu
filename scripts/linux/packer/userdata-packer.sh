#!/bin/bash

<<'SCRIPT-FUNCTIONS'
    Requirements: none
    Description: Script for Install and Configure Packer
    Author: Marcos Silvestrini
    Date: 06/06/2023
SCRIPT-FUNCTIONS

export LANG=C

# Set workdir
cd /home/vagrant || exit

# Variables
DISTRO=$(cat /etc/*release | grep -ws NAME=)

# Variables
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
LIGHTGRAY='\033[0;37m'
DISTRO=$(cat /etc/*release | grep -ws NAME=)

if [[ "$DISTRO" == *"Rocky Linux"* ]]; then
    echo -e "${GREEN}Congratulations! Your distribution has been enabled for this project!!!"
else
    echo -e "${RED}This distribution not enabled for this project.Sorry!!!"
    exit 0
fi
echo -e "${LIGHTGRAY}----------------------------------------------------------------"

# Install packer manual in fedora\rock
# issue: https://github.com/rapid7/metasploitable3/issues/128

echo -e "${ORANGE}Install and Configure Packer..."
echo -e "${GREEN}  "
cd /tmp || exit
rm -rf *packer*
curl -LO https://raw.github.com/robertpeteuil/packer-installer/master/packer-install.sh -o packer-install.sh
chmod +x packer-install.sh
./packer-install.sh -c
chown vagrant:vagrant packer
mkdir /packer_home
mv packer /packer_home
export PATH=/packer_home/:$PATH
ls -lt /tmp
rm -rf *packer*
echo -e "${LIGHTGRAY}----------------------------------------------------------------"

echo -e "${ORANGE}Check Install Packer..."
echo -e "${GREEN}  "
packer --version
