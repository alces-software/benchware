DISK=$1

if [ $(pvs |grep -c $DISK |awk '{print $1}') -gt 0 ] ; then
    mountpath=system
else
    mountpath=$(mount -v |grep "$DISK " |awk '{print $3}')
fi

if [ -z $mountpath ] ; then
   echo 'N/A'
elif [ $mountpath == 'system' ] ; then
   echo 'Not testing - system disk'
else
   dd if=/dev/zero of=$mountpath/dd_speed_test bs=1M count=1024 conv=fsync 2>&1 |grep 'MB/s' |awk '{print $8}'
fi
