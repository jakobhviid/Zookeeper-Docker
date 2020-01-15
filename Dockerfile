FROM ubuntu:18.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends openjdk-8-jre-headless && \
    apt-get install -y netcat

# Setup necessary scripts
COPY scripts configuration.cfg /tmp/
RUN chmod +x /tmp/*.sh && \
    mv /tmp/*.sh /usr/bin && \
    rm -rf /tmp/*.sh

# COPY ./apache-zookeeper-3.5.6-bin.tar /opt/
ADD http://ftp.download-by.net/apache/zookeeper/zookeeper-3.5.6/apache-zookeeper-3.5.6-bin.tar.gz /opt/
RUN cd /opt && \
    tar -xzf apache-zookeeper-3.5.6-bin.tar.gz && \
    mv apache-zookeeper-3.5.6-bin zookeeper && \
    rm -rf ./apache-zookeeper-*tar && \
    cp /tmp/configuration.cfg /opt/zookeeper/conf/zoo.cfg && \
    mkdir /opt/zookeeper/data

EXPOSE 2181 2888 3888

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD [ "healthcheck.sh" ]

CMD ["start.sh"]