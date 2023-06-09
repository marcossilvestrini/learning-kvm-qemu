#!/bin/bash

<<'MULTILINE-COMMENT'
    Requirments: none
    Description: Script for set environment for labs
    Author: Marcos Silvestrini
    Date: 24/03/2023
MULTILINE-COMMENT

export LANG=C

cd /home/vagrant || exit

## Configure access for share
cp configs/samba/.samba-access .
dos2unix .samba-access
chown vagrant:vagrant .samba-access

# Mount Share in /etc/fstab
#-rw-r--r-- 1 root root 652 Mar 24 10:25 /etc/fstab
VM=$(hostname)

## Copy original template for fstab
if [ ! -f "configs/samba/fstab_${VM}_backup" ]; then
    cp /etc/fstab "configs/samba/fstab_${VM}_backup"
fi

# Check fstab uuid
UUID_SERVER=$(echo $(cat /etc/fstab | grep "UUID=" | head -n 1) | cut -d' ' -f1)
UUID_LOCAL=$(echo $(cat "configs/samba/fstab_${VM}_backup" | grep "UUID=" | head -n 1) | cut -d' ' -f1)

if [ "$UUID_SERVER" = "$UUID_LOCAL" ]; then
    echo "UUIDS its ok for deploy"
    echo "UUID Server: $UUID_SERVER"
    echo "UUID Local: $UUID_LOCAL"
else
    echo "ERROR!!! UUIDS not equals."
    echo "We will Copy a nem /etc/fstab for deply,relax guy!!!"
    rm "configs/samba/fstab_${VM}_backup"
    cp /etc/fstab "configs/samba/fstab_${VM}_backup"
fi

## Generate fstab with samba\cifs shares
if [ -f "configs/samba/fstab"  ];then
    rm "configs/samba/fstab"
fi
cp "configs/samba/fstab_${VM}_backup" configs/samba/fstab
cat configs/commons/template-fstab >> configs/samba/fstab
cp configs/samba/fstab /etc/fstab
dos2unix /etc/fstab
chmod 644 /etc/fstab  
systemctl daemon-reload

## Mount CIFS shares
umount /mnt/isos 2>&1
mkdir -p /mnt/isos
mount /mnt/isos
