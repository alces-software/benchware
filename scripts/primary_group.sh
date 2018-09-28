#!/bin/bash -l

# Vars
node="$1"

# Check for nodeattr
command -v nodeattr > /dev/null
if [ $? == 1 ] ; then
  module load services/pdsh
  if [ $? == 1 ] ; then
    echo "nodeattr command missing"
  fi
fi

nodeattr -l $node |paste -s -d ',' |cut -d',' -f1

