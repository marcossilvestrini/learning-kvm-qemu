#!/bin/bash

<<'MULTILINE-COMMENT'
    Requirments: none
    Description: Script for set environment for labs
    Author: Marcos Silvestrini
    Date: 14/02/2023
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
cp -f configs/bind/forwarding/named.conf.local /etc/bind
cp -f configs/commons/named.conf.options /etc/bind

## Apply changes
systemctl enable named
systemctl restart named

## Check config
named-checkconf /etc/bind/named.conf

## Reload named.conf
sudo rndc reload
sudo rndc flush
