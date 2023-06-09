#!/bin/bash

<<'MULTILINE-COMMENT'
    Requirments: none
    Description: Script for Create VM Debian 11 in KVM Server
    Author: Marcos Silvestrini
    Date: 02/06/2023
MULTILINE-COMMENT

# Set language/locale and encoding
export LANG=C

# Set Workdir
cd /home/vagrant || exit

# Clear display
clear

# Create vm using virt-install CLI tool

## set permissions for user
# sudo chown -R $USER:libvirt /var/lib/libvirt/

## Create VM
virt-install \
--name debian11 \
--ram 4096 \
--disk path=/var/lib/libvirt/images/debian11.img,size=20 \
--vcpus 2 \
--os-variant debian10 \
--network bridge=br0 \
--graphics none \
--console pty,target_type=serial \
--location /mnt/isos/Linux/debian-11.6.0-amd64-DVD-1.iso \
--extra-args 'console=ttyS0,115200n8 serial' 