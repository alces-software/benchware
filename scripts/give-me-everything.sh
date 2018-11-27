#!/bin/bash

# Install CentOS/RHEL
# yum install lshw util-linux usbutils pciutils lsscsi dmidecode 
# Install SLES/Suse
# zypper in lshw util-linux usbutils pciutils lsscsi dmidecode
# Install Ubuntu
# apt-get install lshw util-linux usbutils pciutils lsscsi dmidecode

#
# Check for required commands
#
COMMANDS="lshw lscpu lsblk lsusb lspci lsscsi dmidecode"

for cmd in $COMMANDS ; do
    if ! command -v $cmd >/dev/null 2>&1 ;then
        echo "Command '$cmd' not found, ensure it is installed for program to continue"
        echo "Example install commands for various platforms are available in this script"
        echo "Exiting..."
        exit 1
    fi
done

#
# Collect data
#
TMPDIR=$(mktemp -d)
pushd $TMPDIR
lshw > lshw
lshw -short > lshw-short
lscpu > lscpu
lsblk -a > lsblk-a
lsusb -v > lsusb-v
lspci -v > lspci-v
lsscsi > lsscsi
dmidecode > dmidecode
popd

#
# Zip data
#
ZIPFILE="/tmp/$(hostname -s).zip"
pushd $TMPDIR
zip -r $ZIPFILE ./*
popd

rm -rf $TMPDIR
echo "Data written to $ZIPFILE"
