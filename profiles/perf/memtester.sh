#!/bin/bash -l
##SBATCH --exclusive -n 1 --output=/users/alces-cluster/memtester/results/memtest.%j

CORES=$(grep processor /proc/cpuinfo |wc -l)
MEM=$(free -m |grep ^Mem |awk '{print $2}')
MEM95PERC=$((MEM/100*95))
MEMPERCORE=$((MEM95PERC / CORES))

ulimit -l unlimited

if hash memtester 2> /dev/null ; then
    MEMTESTER=$(which memtester)
elif module load apps/memtester 2> /dev/null ; then
    MEMTESTER=$(which memtester)
else
    echo "memtester cannot be found"
    exit 1
fi

i=1
while [ $i -le $CORES ] ; do
   memtester $MEMPERCORE\M 3 > /tmp/memtest.out.$i 2>&1 &
   i=`expr $i + 1`
done

wait
