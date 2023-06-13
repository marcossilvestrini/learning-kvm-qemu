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
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
LIGHTGRAY='\033[0;37m'
DISTRO=$(cat /etc/*release | grep -ws NAME=)
BR_NAME="br0"
BR_INT="eth2"
SUBNET_IP="172.36.12.3/24"
GW="172.36.12.2"
DNS1="192.168.0.130"
DNS2="1.1.1.1"

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

## Clear old connections
WIRED_NAME=$(nmcli -t -f NAME c show | grep "Wired")
while IFS= read -r NAME; do echo nmcli connection delete "$NAME"; done <<< "$WIRED_NAME"

# define the bridge network
nmcli connection add type bridge autoconnect yes con-name ${BR_NAME} ifname ${BR_NAME}

## add the IP, gateway, and DNS to the bridge
nmcli connection modify ${BR_NAME} ipv4.addresses ${SUBNET_IP} ipv4.method manual
nmcli connection modify ${BR_NAME} ipv4.gateway ${GW}
nmcli connection modify ${BR_NAME} ipv4.dns "$DNS1 $DNS2"

## Add the identified network device as a slave to the bridge
nmcli connection add type bridge-slave autoconnect yes con-name ${BR_INT} ifname ${BR_INT} master ${BR_NAME}

## Start the network bridge
nmcli connection down "$(nmcli -t -f NAME,DEVICE c show --active | grep $BR_INT | cut -d : -f 1)"
nmcli connection reload
nmcli connection dow br0
nmcli connection up br0

# Edit file /etc/qemu-kvm/bridge.conf
# -rw-r--r--. 1 root root 13 May  9 04:44 /etc/qemu-kvm/bridge.conf
cp configs/kvm/bridge.conf /etc/qemu-kvm/
dos2unix /etc/qemu-kvm/bridge.conf
chmod 644 /etc/qemu-kvm/bridge.conf

## Restart NetworkManager
systemctl restart NetworkManager

## Restart KVM 
systemctl restart libvirtd
echo -e "${LIGHTGRAY}----------------------------------------------------------------"

# Declaring the KVM Bridged Network
virsh net-define configs/kvm/bridge.xml
virsh net-start br0
virsh net-autostart br0

## check connections
echo -e "${ORANGE}Check Network Status..."
echo -e "${GREEN}$(ip link show br0 && ip addr show br0)"
echo -e "${GREEN}$(nmcli connection show br0 | grep dns)"
echo -e "${GREEN}$(virsh net-list --all)"
echo -e "${LIGHTGRAY}----------------------------------------------------------------"

# Configure KVM Storage Pool

## Mount /dev/sdb - logical volume
echo -e "${ORANGE}Mount /dev/mapper/lab_kvm_storage-lab_kvm_lv ---> /var/lib/libvirt/images..."
mount /var/lib/libvirt/images

# Check Mount Point
echo -e "${ORANGE}Check Mount Point..."
echo -e "${GREEN} "
df -h  /var/lib/libvirt/images
echo -e "${LIGHTGRAY}----------------------------------------------------------------"

## Create Storage Pool
echo -e "${ORANGE}Create Storage Pool..."
echo -e "${GREEN} "
virsh pool-define-as lab_kvm_storagepool --type dir --target /var/lib/libvirt/images
virsh pool-autostart  lab_kvm_storagepool
virsh pool-start  lab_kvm_storagepool

## Check Storage Pool
echo -e "${ORANGE}Check Storage Pool..."
echo -e "${GREEN} "
virsh pool-list --all --details

# Set user permissions for KVM
chown -R vagrant:libvirt /var/lib/libvirt/

# Example for user new bridge network
#virt-install --name demo_vm_guest \
    #--memory 1024 \
    #--disk path=/tmp/demo_vm_guest. img,size=10 \
    #--network network=br0 \
    #--cdrom /home/demo/Rocky-9.1-x86_64-minimal.iso
