#!/bin/bash

<<'MULTILINE-COMMENT'
    Requirments: none
    Description: Script for set environment for labs
    Author: Marcos Silvestrini
    Date: 14/03/2023
MULTILINE-COMMENT

# Set language/locale and encoding
export LANG=C

cd /home/vagrant || exit

# Install packages
dnf install -y bind
dnf install -y bind-utils
dnf install -y bind-dnssec-utils

# Configure BIND

##Config bind caching parameters
#-rw-r-----. 1 root named 1722 Nov 16 08:44 /etc/named.conf
cp -f configs/bind/caching/named.conf /etc

dos2unix /etc/named.conf
chown root:named /etc/named.conf
chmod 640 /etc/named.conf

## Start service
systemctl enable named
systemctl restart named

## Reload named.conf
sudo rndc reconfig
