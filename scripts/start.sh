#!/bin/bash

configure-zookeeper.sh

if [ $? != 0 ]; then
    exit 1
fi

echo "INFO Starting ZooKeeper"

if ! [[ -z "$ZOO_AUTHENTICATION" ]]; then
    shopt -s nocasematch # ignore case of 'kerberos'
    if [[ $ZOO_AUTHENTICATION == KERBEROS ]]; then
        export JVMFLAGS="-Djava.security.auth.login.config="$ZOOKEEPER_HOME"/conf/zookeeper_jaas.conf -Djava.security.krb5.conf="$ZOOKEEPER_HOME"/conf/krb5.conf"
    fi
fi

/opt/zookeeper/bin/zkServer.sh start-foreground
