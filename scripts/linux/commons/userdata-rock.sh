#!/bin/bash

<<'MULTILINE-COMMENT'
    Requirments: none
    Description: Script for set environment for labs
    Author: Marcos Silvestrini
    Date: 20/02/2023
MULTILINE-COMMENT

# Set language/locale and encoding
export LANG=C

# Set workdir
cd /home/vagrant || exit

# Set password account
usermod --password $(echo vagrant | openssl passwd -1 -stdin) vagrant
usermod --password $(echo vagrant | openssl passwd -1 -stdin) root

# Enable Epel repo 
# https://www.linuxcapable.com/how-to-install-epel-on-rocky-linux/
dnf config-manager --set-enabled crb
dnf install -y \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
    https://dl.fedoraproject.org/pub/epel/epel-next-release-latest-9.noarch.rpm

# Install packages
dnf update -y
dnf upgrade --refresh -y
dnf makecache --refresh
dnf install -y bash-completion
dnf install -y vim
dnf install -y dos2unix
dnf install -y sshpass
dnf install -y htop
dnf install -y lsof
dnf install -y tree
dnf install -y net-tools
dnf install -y bind-utils
dnf install -y telnet
dnf install -y traceroute
dnf install -y sysstat
dnf install -y NetworkManager-initscripts-updown
dnf install -y python3-pip
dnf install -y python3-virtualenv
dnf install -y zip


# Set profile in /etc/profile
cp -f configs/commons/profile-rock /etc/profile
dos2unix /etc/profile

# Set vim profile
cp -f configs/commons/.vimrc .
dos2unix .vimrc
chown vagrant:vagrant .vimrc

# Set bash session
cp -f configs/commons/.bashrc-rock .bashrc
dos2unix .bashrc .vimrc
chown root:root .bashrc .vimrc

# Set properties for user root
cp -f .bashrc .vimrc /root/

# Enabling IP forwarding on Linux
cp configs/commons/sysctl.conf /etc
dos2unix /etc/sysctl.conf
systemctl daemon-reload

# SSH,FIREWALLD AND SELINUX
cat security/id_ecdsa.pub >>.ssh/authorized_keys

# rm /etc/ssh/sshd_config.d/90-vagrant.conf
# cp -f configs/commons/01-sshd-custom.conf /etc/ssh/sshd_config.d
# dos2unix /etc/ssh/sshd_config.d
# systemctl restart sshd
# echo vagrant | $(su -c "ssh-keygen -q -t ecdsa -b 521 -N '' -f .ssh/id_ecdsa <<<y >/dev/null 2>&1" -s /bin/bash vagrant)
# systemctl restart sshd
systemctl stop firewalld
systemctl disable firewalld
setenforce Permissive

# Set GnuGP
#echo vagrant | $(su -c "gpg -k" -s /bin/bash vagrant)

# Install X11 Server
# https://installati.one/rockylinux/8/xorg-x11-server-common/
dnf -y install xorg-x11-server-common
dnf -y install xorg-x11-xauth

# Enable sadc collected system activity
cp -f configs/commons/sysstat /etc/default/
dos2unix /etc/default/sysstat
systemctl start sysstat sysstat-collect.timer sysstat-summary.timer
systemctl enable sysstat sysstat-collect.timer sysstat-summary.timer

# Set Default DNS Server

## Copy host file
cp -f configs/commons/hosts /etc
dos2unix /etc/hosts

## Set Networkmanager
cp -f configs/commons/01-NetworkManager-custom.conf /etc/NetworkManager/conf.d/
dos2unix /etc/NetworkManager/conf.d/01-NetworkManager-custom.conf
systemctl reload NetworkManager

## Set resolv.conf file
rm /etc/resolv.conf
cp configs/commons/resolv.conf.manually-configured /etc
dos2unix  /etc/resolv.conf.manually-configured
ln -s /etc/resolv.conf.manually-configured /etc/resolv.conf
