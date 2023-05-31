# LEARNNING GNU\LINUX KVM-QEMU VIRTUALIZATION

![image](https://user-images.githubusercontent.com/62715900/135548567-2f0d21f9-a3ba-41a7-9357-615927bb878f.png)

>This project is about learning KVM for virtualization

## Authors

- Marcos Silvestrini
- marcos.silvestrini@gmail.com

## License

- This project is licensed under the MIT License - see the LICENSE.md file for details

## References

- [KVM Docs](https://www.linux-kvm.org/page/Documents)
- [Install and Configure in Debian](https://www.linuxtechi.com/install-configure-kvm-debian-10-buster/)
- [Create and Manage VM's](https://linuxconfig.org/how-to-create-and-manage-kvm-virtual-machines-from-cli)
- [Create and Manage VM's](https://wiki.debian.org/KVM)

## Install and Configure KVM in Debian

Step:1) Check Whether Virtualization Extension is enabled or not:

```sh
egrep -c '(vmx|svm)' /proc/cpuinfo
grep -E --color '(vmx|svm)' /proc/cpuinfo
```

Step:2) Install QEMU-KVM & Libvirt packages along with virt-manager

```sh
#install libvirt packages
sudo apt install qemu-kvm libvirt-clients libvirt-daemon-system \
bridge-utils virtinst libvirt-daemon virt-manager -y

#osinfo
apt-get install libosinfo-bin

#check status libvirt
sudo systemctl status libvirtd.service
```

Step:3) Start default network and add vhost_net module

```sh
#show network default and Start
sudo virsh net-list --all

#make it active and auto-restart across the reboot
sudo virsh net-start default
sudo virsh net-autostart default

#add “vhost_net” kernel module
sudo modprobe vhost_net

#add user in  libvirt groups
sudo adduser myuser libvirt
sudo adduser myuser libvirt-qemu

#to refresh or reload group membership run the followings,
newgrp libvirt
libvirt-qemu
```

Step:4) Create Linux Bridge(br0) for KVM VMs

```sh
sudo vi /etc/network/interfaces
```

```sh
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug ens34
auto ens34
iface ens34 inet manual

#Configure bridge and give it a static ip
auto br0
iface br0 inet static
        address 192.168.0.133
        netmask 255.255.255.0
        network 192.168.0.1
        broadcast 192.168.0.255
        gateway 192.168.0.1
        bridge_ports ens34
        bridge_stp off
        bridge_fd 0
        bridge_maxwait 0
        dns-nameservers 1.1.1.1

# This is an autoconfigured IPv6 interface
iface ens34 inet6 auto
```

```sh
#reboot system
sudo reboot

#check network changes
ip a s br0
```

## Default Paths for VMs

$HOME/.local/share/libvirt/images\
/var/lib/libvirt/images

## List of all supported systems

```sh
osinfo-query os
```

## Create the new virtual machine

```sh
virt-install --name=debian-11-x64 \
--vcpus=1 \
--memory=1024 \
--cdrom=/mnt/isos/Linux/debian-11.0.0-amd64-DVD-1.iso \
--disk size=5 \
--os-variant=debian9
```
