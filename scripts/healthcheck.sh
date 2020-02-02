#!/bin/bash

# Check to see if zookeeper process is running inside container
zookeeperProcess=`ps -x | grep java | grep zookeeper`

if ! [[ -z "$zookeeperProcess" ]] # If zookeeperProcess is not empty
then
    # Check to see if it's possible to communicate with the zookeeper server (Trying to get ids of all kafka brokers)
    zookeeperConnectedInfo=zookeeperInformation=`/opt/zookeeper/bin/zkCli.sh -server localhost:$ZOO_PORT <<< "create /HEALTHCHECK-TEST-$ZOO_PORT test" | grep "CONNECTED"`

    if ! [[ -z "$zookeeperConnectedInfo" ]] # If zookeeperConnectedInfo is NOT empty (zookeeper is connected)
    then
        # Delete created node
        /opt/zookeeper/bin/zkCli.sh -server localhost:$ZOO_PORT <<< "delete /HEALTHCHECK-TEST-$ZOO_PORT"
        echo " OK "
        exit 0
    fi
fi
# TODO - Potentially create more checks with latency and node count etc.

echo " BAD "
exit 1
