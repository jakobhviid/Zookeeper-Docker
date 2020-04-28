#!/bin/bash

if [[ -z "$ZOO_ID" ]]; then
    echo -e "\e[1;32mERROR - Missing essential zookeeper machine id. \e[0m"
    exit 1
else
    touch /data/zookeeper/myid
    echo $ZOO_ID >>/data/zookeeper/myid
fi

if [ -z "$ZOO_PORT" ]; then
    echo -e "\e[1;32mERROR - Missing essential zookeeper port \e[0m"
    exit 1
else
    # Client port in zookeepeer configuration file
    echo -e "\nclientPort="$ZOO_PORT >>"$ZOOKEEPER_HOME"/conf/zoo.cfg
fi

echo "INFO - Configuring ZooKeeper"

# TODO - Add check if the string uses the reight delimter (;) and no other spaces, just use a regex
if [ -z "$ZOO_SERVERS" ]; then
    echo "INFO - Missing 'ZOO_SERVERS' for multi clustered setup - Running standalone"
else
    # Clustered(Multi-server) zookeeper setup
    IFS=',' # Internal field seperator
    read -r -a zookeepers <<<"$ZOO_SERVERS"
    for zookeeperServer in "${zookeepers[@]}"; do
        echo -e "\n$zookeeperServer" >>"$ZOOKEEPER_HOME"/conf/zoo.cfg
    done
fi

function configure_kerberos_server_in_krb5_file() {
    if [ "$#" -ne 2 ]; then
        echo -e "\e[1;32mconfigure_kerberos_server_in_krb5_file not used correctly! Provide two parameters (public url of kerberos server and kerberos realm) \e[0m"
    else
        printf "\n[realms]\n"$1" = {\nadmin_server="$2"\nkdc="$2"\n}" >>"$ZOOKEEPER_HOME"/conf/krb5.conf
        awk -v kerberos_realm=${1} '/default_realm/{c++;if(c==1){sub("default_realm.*","default_realm="kerberos_realm);c=0}}1' "$ZOOKEEPER_HOME"/conf/krb5.conf >/tmp/tmpfile && mv /tmp/tmpfile "$ZOOKEEPER_HOME"/conf/krb5.conf
    fi
}

if ! [[ -z "$ZOO_AUTHENTICATION" ]]; then
    shopt -s nocasematch # ignore case of 'kerberos'
    if [[ ${ZOO_AUTHENTICATION} == KERBEROS ]]; then
        # test if a keytab has been provided in the expected directory
        keytab_location=""$ZOOKEEPER_SASL_HOME"/zookeeper.service.keytab"
        if ! [[ -f "${keytab_location}" ]]; then
            echo -e "\e[1;32mERROR - Missing kerberos keytab file '/sasl/zookeeper.service.keytab'. This is required to enable kerberos. Provide it with a docker volume or docker mount \e[0m"
            exit 1
        fi

        if [[ -z "${KERBEROS_PRINCIPAL}" ]]; then
            echo -e "\e[1;32mERROR - Missing 'KERBEROS_PRINCIPAL' environment variable. This is required to enable kerberos \e[0m"
            exit 1
        fi

        if [[ -z "${KERBEROS_PUBLIC_URL}" ]]; then
            echo -e "\e[1;32mERROR - Missing 'KERBEROS_PUBLIC_URL' environment variable. This is required to enable kerberos \e[0m"
            exit 1
        fi

        if [[ -z "${KERBEROS_REALM}" ]]; then
            echo -e "\e[1;32mERROR - Missing 'KERBEROS_REALM' environment variable. This is required to enable kerberos \e[0m"
            exit 1
        fi

        # Configure zookeeper to use sasl authentication (kerberos) and renew the ticket every hour.
        printf "\nauthProvider.1=org.apache.zookeeper.server.auth.SASLAuthenticationProvider\njaasLoginRenew=3600000\n" >>"$ZOOKEEPER_HOME"/conf/zoo.cfg

        # Create and replace contents in the zookeeper_jaas.conf which zookeeper will use as sasl identity
        touch "$ZOOKEEPER_HOME"/conf/zookeeper_jaas.conf
        printf "Server {\n\tcom.sun.security.auth.module.Krb5LoginModule required\n\tuseKeyTab=true\n\tstoreKey=true\n\tkeyTab=\""$keytab_location"\"\n\tprincipal=\""$KERBEROS_PRINCIPAL"\";\n};\n" >"$ZOOKEEPER_HOME"/conf/zookeeper_jaas.conf

        # configure krb5.conf for kerberos server
        configure_kerberos_server_in_krb5_file "$KERBEROS_REALM" "$KERBEROS_PUBLIC_URL"
    fi
fi
