#!/bin/bash

<<'MULTILINE-COMMENT'
    Requirments: none
    Description: Script for Create VM Rocklinux 9 in KVM Server
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

virt-install \
--name Rocky9 \
--ram 2048 \
--vcpus 1 \
--disk path=/var/lib/libvirt/images/rocky-9.img,size=20 \
--os-variant centos-stream9 \
--os-type linux \
--network bridge=br0,model=virtio \
--graphics vnc,listen=0.0.0.0 \
--console pty,target_type=serial \
--location /mnt/isos/Linux/Rocky-9.1-x86_64-dvd.iso