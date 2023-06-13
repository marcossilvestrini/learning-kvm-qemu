#!/bin/bash

<<'MULTILINE-COMMENT'
    Requirments: none
    Description: Script for Configure Network in KVM Server 01
    Author: Marcos Silvestrini
    Date: 05/06/2023
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


# Set network
echo -e "${ORANGE}Set Network [eth1,virbr0]..."

## Enable the IPv4 forwarding
echo -e "${ORANGE}Enable the IPv4 forwarding..."
echo net.ipv4.ip_forward = 1 | tee /usr/lib/sysctl.d/60-libvirtd.conf > /dev/null
echo -e "${GREEN}$(/sbin/sysctl -p /usr/lib/sysctl.d/60-libvirtd.conf)"
echo -e "${LIGHTGRAY}----------------------------------------------------------------"

## Dow links\interfaces
ip link set eth1 down 
ip link set virbr0 down

## Delete old connections
#WIRED_UUIDS=$(nmcli connection show | grep "Wired connection" | grep -E -o '[0-9a-f\-]{36}')
WIRED_NAME=$(nmcli -t -f NAME c show | grep "Wired")
while IFS= read -r NAME; do echo nmcli connection delete "$NAME"; done <<< "$WIRED_NAME"
nmcli --fields UUID,TIMESTAMP-REAL con show | grep never |  awk '{print $1}' | while read -r line; do nmcli con delete uuid  "$line"; done

## Clear interfaces ips
ip addr flush eth1
ip addr flush virbr0

## set interfaces for new values
cp configs/network/ifcfg-eth1 /etc/sysconfig/network-scripts/
cp configs/network/ifcfg-virbr0 /etc/sysconfig/network-scripts/
dos2unix -q /etc/sysconfig/network-scripts/ifcfg-eth1
dos2unix -q /etc/sysconfig/network-scripts/ifcfg-virbr0
chmod 644 /etc/sysconfig/network-scripts/ifcfg-eth1
chmod 644 /etc/sysconfig/network-scripts/ifcfg-virbr0

# ## Set UUID for interfaces
# uuidgen eth1 >/tmp/uuid-eth1
# uuidgen virbr0 > /tmp/uuid-virbr0
# UUID_ETH1=$(cat /tmp/uuid-eth1)
# UUID_VIRBR0=$(cat /tmp/uuid-virbr0)
# sed -i  "s/newuuid/$UUID_ETH1/g" /etc/sysconfig/network-scripts/ifcfg-eth1
# sed -i  "s/newuuid/$UUID_VIRBR0/g" /etc/sysconfig/network-scripts/ifcfg-virbr0

## Set MAC for virbr0
#ip link set dev eth1 address 08:00:27:f3:06:6a
#ip link set dev virbr0 address 08:00:27:f3:06:6c

## Configure Firewall
#firewall-cmd --permanent --direct --passthrough ipv4 -I FORWARD -i bridge0 -j ACCEPT
# firewall-cmd --permanent --direct --passthrough ipv4 -I FORWARD -o bridge0 -j ACCEPT
# firewall-cmd --reload
