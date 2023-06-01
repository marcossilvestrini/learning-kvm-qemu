#!/bin/bash
<<'SCRIPT-FUNCTION'
    Description: Script for check pure-ftp Stack
    Author: Marcos Silvestrini
    Date: 24/04/2023
SCRIPT-FUNCTION

#Set localizations for prevent bugs in operations
LANG=C

# Set workdir
cd /home/vagrant || exit

#Variables
IP_VM_OL9_01="192.168.0.130"
IP_VM_DEBIAN_01="192.168.0.140"


# File for outputs testing
FILE_TEST=test/pure-ftp/check-pureftp-stack.txt
LINE="------------------------------------------------------"

echo $LINE >$FILE_TEST
echo "Check pure-ftp Stack for This Lab" >>$FILE_TEST
DATE=$(date '+%Y-%m-%d %H:%M:%S')
echo "Date: $DATE" >>$FILE_TEST
echo -e "$LINE\n" >>$FILE_TEST

# Check pure-ftp status
echo $LINE >>$FILE_TEST
echo -e "Check Status of pure-ftp in server $IP_VM_OL9_01...\n" >>$FILE_TEST
sshpass -p 'vagrant' ssh -o StrictHostKeyChecking=no vagrant@$IP_VM_OL9_01 -l vagrant \
    systemctl status pure-ftpd | grep "Active" >>$FILE_TEST    
echo $LINE >>$FILE_TEST

echo $LINE >>$FILE_TEST
echo -e "Check Status of pure-ftp in server $IP_VM_DEBIAN_01...\n" >>$FILE_TEST
sshpass -p 'vagrant' ssh -o StrictHostKeyChecking=no vagrant@$IP_VM_DEBIAN_01 -l vagrant \
    systemctl status pure-ftpd | grep "Active" >>$FILE_TEST    
echo $LINE >>$FILE_TEST

# Check version of pure-ftp
echo -e "Check version of pure-ftp in server $IP_VM_OL9_01...\n" >>$FILE_TEST
sshpass -p 'vagrant' ssh -o StrictHostKeyChecking=no vagrant@$IP_VM_OL9_01 -l vagrant \
    sudo yum info pure-ftpd >>$FILE_TEST     
echo $LINE >>$FILE_TEST

echo -e "Check version of pure-ftp in server $IP_VM_DEBIAN_01...\n" >>$FILE_TEST
sshpass -p 'vagrant' ssh -o StrictHostKeyChecking=no vagrant@$IP_VM_DEBIAN_01 -l vagrant \
    sudo apt-cache showpkg pure-ftpd >>$FILE_TEST
echo $LINE >>$FILE_TEST
