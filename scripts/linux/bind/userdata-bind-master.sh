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

# Install packages
dnf install -y bind
dnf install -y bind-utils
dnf install -y whois
dnf install -y bind-dnssec-utils
dnf install -y bind-chroot

# Configure BIND

## Stop bind
systemctl stop named

## Config Bind master
#-rw-r-----. 1 root named 1722 Nov 16 08:44 /etc/named.conf
cp -f configs/bind/master/named.conf /etc
dos2unix /etc/named.conf
chown root:named /etc/named.conf
chmod 640 /etc/named.conf

## Set zone file with type records (SOA,NS,MX,A,TXT,etc)
cp -f configs/bind/master/skynet.zone /var/named
dos2unix /var/named/skynet.zone
chown root:named /var/named/skynet.zone
chmod 640 /var/named/skynet.zone

## Set reverse zone file with type record (PTR) - Network 192.168.0.0/24
cp -f configs/bind/master/0.168.192.in-addr.arpa.zone /var/named
dos2unix /var/named/0.168.192.in-addr.arpa.zone
chown root:named /var/named/0.168.192.in-addr.arpa.zone
chmod 640 /var/named/0.168.192.in-addr.arpa.zone

## Set reverse zone file with type record (PTR) - Network 172.36.12.0/24
cp -f configs/bind/master/12.36.172.in-addr.arpa.zone /var/named
dos2unix /var/named/12.36.172.in-addr.arpa.zone
chown root:named /var/named/12.36.172.in-addr.arpa.zone
chmod 640 /var/named/12.36.172.in-addr.arpa.zone

## Sign DNSSEC key
cp configs/bind/master/Kskynet.com.br.+013+29838.* /var/named
dnssec-signzone -P -o skynet.com.br /var/named/skynet.zone /var/named/Kskynet.com.br.+013+29838.private

## chroot jail (Running BIND9 in a chroot cage)
/usr/libexec/setup-named-chroot.sh /var/named/chroot on

## Start service
systemctl restart named-chroot
systemctl enable named-chroot

## Validate zone file
named-checkzone skynet.com.br /var/named/skynet.zone
named-checkzone skynet.com.br /var/named/skynet.zone.signed

## Reload named.conf
sudo rndc reconfig
sudo rndc reload
