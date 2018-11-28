#!/bin/bash

NODE=$1

# Install CentOS/RHEL
# yum install lshw util-linux 
# Install SLES/Suse
# zypper in lshw util-linux 
# Install Ubuntu
# apt-get install lshw util-linux 

#
# Check for required commands
#
ssh $NODE '
COMMANDS="lshw lscpu" 
for cmd in $COMMANDS ; do
    if ! command -v $cmd >/dev/null 2>&1 ;then
        echo "Command $cmd not found, ensure it is installed for program to continue"
        echo "Example install commands for various platforms are available in this script"
        echo "Exiting..."
        exit 1
    fi
done'

#
# Collect data
#
TMPDIR=$(mktemp -d)
pushd $TMPDIR
ssh $NODE "lshw -xml" > lshw-xml
ssh $NODE "lsblk -a -P" > lsblk-a-P
popd

#
# Zip data
#
ZIPFILE="/tmp/$(ssh $NODE "hostname -s").zip"
pushd $TMPDIR
zip -r $ZIPFILE ./*
popd

rm -rf $TMPDIR
echo "Data written to $ZIPFILE"
