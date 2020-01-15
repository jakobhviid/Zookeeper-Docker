#!/bin/bash

# TODO - dynamic port
# TODO - Can i communicate and get a lsit of broker id
# TODO - CHeck binary inside
zookeeperInformation=`echo stat | nc localhost 2181`

if [ -z "$zookeeperInformation" ]
then
    # Create more checks with latency and node count etc.
    echo " BAD "
    exit 1
else
    echo " OK "
    exit 0
fi
