#!/bin/bash

if [[ -z "$ZOO_ID" ]]
then 
    echo "ERROR Missing essential zookeeper machine id."
    exit 1
fi

if [ -z "$ZOO_PORT" ]
then 
    echo "ERROR Missing essential zookeeper port"
    exit 1
fi

echo "INFO Configuring ZooKeeper"

# TODO - Add check if the string uses the reight delimter (;) and no other spaces, just use a regex
if [ -z "$ZOO_SERVERS" ] 
then 
    echo "INFO Missing zookeeper servers for multi clustered setup - Running standalone"
else
    echo "INFO ZOO_SERVERS set - Deploying multi-clustered setup"

    # Clustered(Multi-server) zookeeper setup
    IFS=',' # Internal field seperator
    read -r -a zookeepers <<< "$ZOO_SERVERS"
    for zookeeperServer in "${zookeepers[@]}"
    do
        echo -e "\n$zookeeperServer" >> /opt/zookeeper/conf/zoo.cfg
    done
fi

# Server.id insertion necessarry for a multi clustered setup
touch /data/zookeeper/myid
echo $ZOO_ID >> /data/zookeeper/myid

# Client port in zookeepeer configuration file
echo -e "\nclientPort="$ZOO_PORT >> /opt/zookeeper/conf/zoo.cfg

echo "INFO Starting ZooKeeper"

/opt/zookeeper/bin/zkServer.sh start-foreground