#!/bin/bash

<<'MULTILINE-COMMENT'
    Requirments: none
    Description: Script for Configure Bind Master
    Author: Marcos Silvestrini
    Date: 13/04/2023
MULTILINE-COMMENT

# Set language/locale and encoding
export LANG=C

cd /home/vagrant || exit

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
echo -e "${ORANGE}[Install and Configure Bind DNS Server]"
echo -e "${LIGHTGRAY}----------------------------------------------------------------"

# Install packages
echo -e "${ORANGE}Install packages..."
echo -e "${GREEN}  "
dnf install -y bind
dnf install -y bind-utils
dnf install -y whois
dnf install -y bind-dnssec-utils
dnf install -y bind-chroot
echo -e "${LIGHTGRAY}----------------------------------------------------------------"

# Configure BIND
echo -e "${ORANGE}[Configure Bind]"

## Stop bind
echo -e "${ORANGE}Stop Bind..."
echo -e "${GREEN}  "
systemctl stop named
echo -e "${LIGHTGRAY}----------------------------------------------------------------"

## Config Bind master
echo -e "${ORANGE}Set file /etc/named.conf..."
echo -e "${GREEN}  "
#-rw-r-----. 1 root named 1722 Nov 16 08:44 /etc/named.conf
cp -f configs/bind/master/named.conf /etc
dos2unix /etc/named.conf
chown root:named /etc/named.conf
chmod 640 /etc/named.conf
echo -e "${LIGHTGRAY}----------------------------------------------------------------"

## Set zone file with type records (SOA,NS,MX,A,TXT,etc)
echo -e "${ORANGE}Set zone file with type records (SOA,NS,MX,A,TXT,etc)..."
echo -e "${GREEN}  "
cp -f configs/bind/master/skynet.zone /var/named
dos2unix /var/named/skynet.zone
chown root:named /var/named/skynet.zone
chmod 640 /var/named/skynet.zone
echo -e "${LIGHTGRAY}----------------------------------------------------------------"

## Set reverse zone file with type record (PTR) - Network 192.168.0.0/24
echo -e "${ORANGE}Set reverse zone file with type record (PTR) - Network 192.168.0.0/24..."
echo -e "${GREEN}  "
cp -f configs/bind/master/0.168.192.in-addr.arpa.zone /var/named
dos2unix /var/named/0.168.192.in-addr.arpa.zone
chown root:named /var/named/0.168.192.in-addr.arpa.zone
chmod 640 /var/named/0.168.192.in-addr.arpa.zone
echo -e "${LIGHTGRAY}----------------------------------------------------------------"

## Set reverse zone file with type record (PTR) - Network 172.36.12.0/24
echo -e "${ORANGE}Set reverse zone file with type record (PTR) - Network 172.36.12.0/24..."
echo -e "${GREEN}  "
cp -f configs/bind/master/12.36.172.in-addr.arpa.zone /var/named
dos2unix /var/named/12.36.172.in-addr.arpa.zone
chown root:named /var/named/12.36.172.in-addr.arpa.zone
chmod 640 /var/named/12.36.172.in-addr.arpa.zone
echo -e "${LIGHTGRAY}----------------------------------------------------------------"

## Sign DNSSEC key
echo -e "${ORANGE}Sign DNSSEC key..."
echo -e "${GREEN}  "
cp configs/bind/master/Kskynet.com.br.+013+29838.* /var/named
dnssec-signzone -P -o skynet.com.br /var/named/skynet.zone /var/named/Kskynet.com.br.+013+29838.private
echo -e "${LIGHTGRAY}----------------------------------------------------------------"

## chroot jail (Running BIND9 in a chroot cage)
echo -e "${ORANGE}chroot jail (Running BIND9 in a chroot cage)..."
echo -e "${GREEN}  "
/usr/libexec/setup-named-chroot.sh /var/named/chroot on
echo -e "${LIGHTGRAY}----------------------------------------------------------------"

## Start service
echo -e "${ORANGE}Start service named-chroot..."
echo -e "${GREEN}  "
systemctl restart named-chroot
systemctl enable named-chroot
echo -e "${LIGHTGRAY}----------------------------------------------------------------"

## Validate zone file
echo -e "${ORANGE}Validate zone file..."
echo -e "${GREEN}  "
named-checkzone skynet.com.br /var/named/skynet.zone
named-checkzone skynet.com.br /var/named/skynet.zone.signed
echo -e "${LIGHTGRAY}----------------------------------------------------------------"

## Reload named.conf
echo -e "${ORANGE}Reload named.conf..."
echo -e "${GREEN}  "
sudo rndc reconfig
sudo rndc reload
echo -e "${LIGHTGRAY}----------------------------------------------------------------"