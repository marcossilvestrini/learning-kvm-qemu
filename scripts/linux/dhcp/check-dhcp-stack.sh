#!/bin/bash
<<'SCRIPT-FUNCTION'
    Description: Script for check stack of ISC DHCP server
    Author: Marcos Silvestrini
    Date: 14/04/2023
SCRIPT-FUNCTION

#Set localizations for prevent bugs in operations
LANG=C

# Set workdir
cd /home/vagrant || exit

# Variables
IP_DHCP="192.168.0.140"

# File for outputs testing
FILE_TEST=test/dhcp/check-dhcp-stack.txt
LINE="------------------------------------------------------"

echo $LINE >$FILE_TEST
echo "Check ISC DHCP Stack for This Lab" >>$FILE_TEST
DATE=$(date '+%Y-%m-%d %H:%M:%S')
echo "Date: $DATE" >>$FILE_TEST
echo -e "$LINE\n" >>$FILE_TEST

## Check version of dhcp
echo -e "Check version of isc dhcp server..." >>$FILE_TEST
sshpass -p 'vagrant' ssh -o StrictHostKeyChecking=no vagrant@$IP_DHCP -l vagrant sudo dhcpd --version >>$FILE_TEST 2>&1
echo $LINE >>$FILE_TEST

## Check status of dhcp
echo -e "Check status of service isc dhcp server..." >>$FILE_TEST
sshpass -p 'vagrant' ssh -o StrictHostKeyChecking=no vagrant@$IP_DHCP -l vagrant sudo systemctl status isc-dhcp-server.service | grep "isc-dhcp-server.service" -ws -A 3  >>$FILE_TEST
echo $LINE >>$FILE_TEST

## Check /etc/dhcp/dhcpd.conf
echo -e "Check file /etc/dhcp/dhcpd.conf...\n" >>$FILE_TEST
sshpass -p 'vagrant' ssh -o StrictHostKeyChecking=no vagrant@$IP_DHCP -l vagrant sudo cat /etc/dhcp/dhcpd.conf | grep -ws "Set DHCP Range" -A 5 >>$FILE_TEST
sshpass -p 'vagrant' ssh -o StrictHostKeyChecking=no vagrant@$IP_DHCP -l vagrant sudo cat /etc/dhcp/dhcpd.conf | grep -ws "Set DHCP clients" -A 5 >>$FILE_TEST
echo $LINE >>$FILE_TEST

## Validate dhcp leases in server
echo -e "Validate dhcp leases in server...\n" >>$FILE_TEST
sshpass -p 'vagrant' ssh -o StrictHostKeyChecking=no vagrant@$IP_DHCP -l vagrant sudo cat /var/lib/dhcp/dhcpd.leases  >>$FILE_TEST
echo $LINE >>$FILE_TEST

## Validate dhcp leases in client
echo -e "Validate dhcp leases in client...\n" >>$FILE_TEST
sudo cat /var/lib/dhcp/dhclient.eth2.leases | grep -ws "lease {" -A 14 | head -14  >>$FILE_TEST
echo $LINE >>$FILE_TEST
