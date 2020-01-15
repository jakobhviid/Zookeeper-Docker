#!/bin/bash

if [[ -z "$ZOO_ID" ]]
then 
    echo "ERROR Missing essential zookeeper machine id."
    exit 1
# else
#     if ! [[ $ZOO_ID =~ ^-?[0-9]+$ ]] && [ $ZOO_ID -ge 1 -a $ZOO_ID -le 255 ]; # ZOO_ID is a valid integer
#     then
#         echo "ERROR ZOO_ID must be between 1 - 255"
#         exit 1
#     fi
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
    IFS=';' # Internal fioeld seperator
    read -r -a zookeepers <<< "$ZOO_SERVERS"
    for zookeeperServer in "${zookeepers[@]}"
    do
        echo -e "\n$zookeeperServer" >> /opt/zookeeper/conf/zoo.cfg
    done
fi

# Server.id insertion necessarry for a multi clustered setup
touch /opt/zookeeper/data/myid
echo $ZOO_ID >> /opt/zookeeper/data/myid

# Client port in zookeepeer configuration file
echo -e "\nclientPort="$ZOO_PORT >> /opt/zookeeper/conf/zoo.cfg

echo "INFO Starting ZooKeeper"

/opt/zookeeper/bin/zkServer.sh start-foreground