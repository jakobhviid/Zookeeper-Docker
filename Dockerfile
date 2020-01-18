FROM ubuntu:18.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends openjdk-8-jre-headless && \
    apt-get install -y netcat

# Setup necessary scripts
COPY scripts configuration.cfg /tmp/
RUN chmod +x /tmp/*.sh && \
    mv /tmp/*.sh /usr/bin && \
    rm -rf /tmp/*.sh

ADD https://apache.org/dist/zookeeper/zookeeper-3.4.14/zookeeper-3.4.14.tar.gz /opt/
RUN cd /opt && \
    tar -xzf zookeeper-3.4.14.tar.gz && \
    mv zookeeper-3.4.14 zookeeper && \
    rm /opt/zookeeper-3.4.14.tar.gz && \
    cp /tmp/configuration.cfg /opt/zookeeper/conf/zoo.cfg && \
    mkdir /data && \
    mkdir /data/zookeeper


EXPOSE 2181 2888 3888

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD [ "healthcheck.sh" ]

WORKDIR /opt/zookeeper
# VOLUME [ "/data/zookeeper" ]

CMD ["start.sh"]