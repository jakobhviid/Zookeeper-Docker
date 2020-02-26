# How to use

A docker-compose file have been provided as an example.

This docker-compose demonstrates deployment of a single zookeeper instance on a machine. It is not recommended to deploy more than one zookeeper instance per hostmachine.

It is necessary to open ports on the host machine. 2181 (client connections) and 2888 + 3888 (zookeeper instances communication, the first port is for connection to leader and the second is for leader election)

```
version: "3"

services:
  zoo:
    image: cfei/zookeeper
    container_name: zookeeper
    ports:
      - "2181:2181"
      - "2888:2888"
      - "3888:3888"
    environment:
      ZOO_ID: 1
      ZOO_PORT: 2181
      ZOO_SERVERS: server.1=0.0.0.0:2888:3888,server.2=178.62.223.195:2888:3888,server.3=188.166.44.123:2888:3888
    restart: always

```

A few environment variabels are required for zookeeper to work properly in a cluster. Some environemnt variables can also be set but is not required as defaults work out of the box.

# Configuration

**Configurations required for a clustered setup**

- `ZOO_ID`: A unique Id for each zookeeper instance in the cluster. This is used by zookeeper to know which of the servers defined in ZOO_SERVERS itself is.

- `ZOO_PORT`: The port on which clients connects to zookeeper. (TODO - Change name to ZOO_CLIENT_PORT)

- `ZOO_SERVERS`: A comma-separated list of all the zookeeeper instances in the cluster needs to be defined here, either with DNS-resolvable hostnames or IP-addresses. An element in the list follows this convention: server.<ZOO_ID>=<ip_address_of_server>:<leader_connection_port>:<leader_selection_port>. **Note:** It is possible to use wildcards here as can be seen in the docker-compose example where the zookeepers' own IP-address is 0.0.0.0.

**Configurations with defaults for a clustered setup (TODO - These have not been implemented yet, so default values are set)**

- `ZOO_TICK_TIME`: Time unit measured in miliseconds used in Zookeeper configurations such as `ZOO_INIT_LIMIT`. Default is 2000 miliseconds - 2 seconds.

- `ZOO_INIT_LIMIT`: Amount of time in ticks for zookeeper followers to connect and sync to the leader. Default is 10 ticks.

- `ZOO_SYNC_LIMIT`: Amount of time in ticks for followers to sync with leader. Default is 5 ticks.

- `ZOO_MAX_CLIENT_CNXNS`: Max amount of clients allowed to connect to a single zookeeper instance. Default is 10. Used to prevent DoS attacks.

- `ZOO_MIN_SESSION_TIMEOUT`: Mininimum amouint of time that a client is allowed to negotiate with the server. Default is 2 times `ZOO_TICK_TIME`

- `ZOO_MAX_SESSION_TIMEOUT`: Maximum amouint of time that a client is allowed to negotiate with the server. Default is 20 times `ZOO_TICK_TIME`

# Volumes

- `/data/zookeeper`: Zookeeper `ZOO_ID` is stored here. Zookeeper also stores database snapshots here which is amde when updates are made to the znode data structure. ZooKeeper will use these snapshots to recover from faults in the event it goes down. This directory is therefore very important to store.

- `/datalogs/zookeeper`: Zookeeper transaction logs. Before ZooKeeper creates a snapshot it makes sure to create a transaction log describing the update.
