#!/bin/bash

<<'MULTILINE-COMMENT'
    Requirments: none
    Description: Script for Install and Configure KVM module in Server
    Author: Marcos Silvestrini
    Date: 02/06/2023
MULTILINE-COMMENT

# Set language/locale and encoding
export LANG=C

# Set Workdir
cd /home/vagrant || exit

# Clear display
clear

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

# Install and configure KVM in Rock linux(RHEL)
# https://computingforgeeks.com/install-use-kvm-virtualization-on-rocky/

## Check compatibility
echo -e "${ORANGE}Check compatibility..."
echo -e "${GREEN}  "
lscpu | grep Virtualization

## Install the Packages
echo -e "${ORANGE}Install Packages..."
echo -e "${GREEN}  "
dnf install -y \
qemu-kvm \
virt-manager \
libvirt \
virt-install \
virt-viewer \
virt-top \
bridge-utils \
libguestfs-tools
echo -e "${LIGHTGRAY}----------------------------------------------------------------"

## Check install
echo -e "${ORANGE}Check Install..."
echo -e "${GREEN}$(lsmod | grep kvm)"
echo -e "${LIGHTGRAY}----------------------------------------------------------------"
echo -e "${BLUE} "

# ## Enable and Start the Services
echo -e "${ORANGE}Enable service..."
echo -e "${LIGHTGRAY}----------------------------------------------------------------"
systemctl enable libvirtd > /dev/null
systemctl start libvirtd > /dev/null
echo -e "${ORANGE}Check Status..."
echo -e "${GREEN}$(systemctl status libvirtd | grep -ws "Active:")"
echo -e "${LIGHTGRAY}----------------------------------------------------------------"

## Also need to ensure the kernel modules for KVM are loaded.
echo -e "${ORANGE}Check Modules..."
echo -e "${GREEN}$(modinfo kvm| grep -E 'filename|name|author|rhelversion|vermagic')"
echo -e "${LIGHTGRAY}----------------------------------------------------------------"
echo -e "${GREEN}$(modinfo kvm_intel| grep -E 'filename|name|author|rhelversion|vermagic')"

# Add your system user to the KVM group
echo -e "${ORANGE}Add your system user to the KVM group..."
usermod -aG libvirt vagrant
newgrp libvirt
echo -e "${LIGHTGRAY}----------------------------------------------------------------"

# Create a Network Bridge for KVM instances
echo -e "${ORANGE}Create a Network Bridge for KVM instances..."
echo -e "${GREEN} "

## Variables
BR_NAME="br0"
BR_INT="eth1"
SUBNET_IP="172.36.12.2/24"
GW="172.36.12.1"
DNS1="192.168.0.130"
DNS2="1.1.1.1"

## define the bridge network
nmcli connection add type bridge autoconnect yes con-name ${BR_NAME} ifname ${BR_NAME}

## add the IP, gateway, and DNS to the bridge
nmcli connection modify ${BR_NAME} ipv4.addresses ${SUBNET_IP} ipv4.method manual
nmcli connection modify ${BR_NAME} ipv4.gateway ${GW}
nmcli connection modify ${BR_NAME} ipv4.dns ${DNS1} +ipv4.dns ${DNS2}

## Clear old connections
WIRED_NAME=$(nmcli -t -f NAME c show | grep "Wired")
while IFS= read -r NAME; do echo nmcli connection delete "$NAME"; done <<< "$WIRED_NAME"

## Add the identified network device as a slave to the bridge
nmcli connection add type bridge-slave autoconnect yes con-name ${BR_INT} ifname ${BR_INT} master ${BR_NAME}

## Start the network bridge
nmcli connection up br0

# Edit file /etc/qemu-kvm/bridge.conf
# -rw-r--r--. 1 root root 13 May  9 04:44 /etc/qemu-kvm/bridge.conf
cp configs/kvm/bridge.conf /etc/qemu-kvm/
dos2unix /etc/qemu-kvm/bridge.conf
chmod 644 /etc/qemu-kvm/bridge.conf

## Restart KVM 
systemctl restart libvirtd
echo -e "${LIGHTGRAY}----------------------------------------------------------------"

## check connections
echo -e "${ORANGE}Check Network Status..."
echo -e "${GREEN}$(ip link show br0 && ip addr show br0)"
echo -e "${GREEN}$(virsh net-list)"
echo -e "${LIGHTGRAY}----------------------------------------------------------------"

