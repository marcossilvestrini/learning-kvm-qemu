#!/bin/bash

<<'MULTILINE-COMMENT'
    Requirments: none
    Description: Script for set environment for labs
    Author: Marcos Silvestrini
    Date: 14/04/2023
MULTILINE-COMMENT

# Set language/locale and encoding
export LANG=C

cd /home/vagrant || exit

# Install packages
apt-get install -y bind9
apt-get install -y dnsutils
apt-get install -y xserver-xorg

# Configure BIND

## Config Bind master
cp -f configs/bind/slave/named.conf.local /etc/bind
cp -f configs/commons/named.conf.options /etc/bind
dos2unix /etc/bind/named.conf.local
dos2unix /etc/bind/named.conf.options

## Apply changes
systemctl restart named
systemctl enable named

## Reload named.conf
sudo rndc reload

## Force retransmission
#sudo rndc retransfer skynet.com.br
