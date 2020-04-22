FROM ubuntu:18.04

ENV ZOOKEEPER_HOME=/opt/zookeeper

RUN apt update && \
    apt install -y --no-install-recommends openjdk-8-jre-headless

# Copy necessary scripts + configuration
COPY scripts configuration.cfg /tmp/
RUN chmod +x /tmp/*.sh && \
    mv /tmp/*.sh /usr/bin && \
    rm -rf /tmp/*.sh

# Install Zookeeper
COPY zookeeper-3.4.14.tar.gz /opt/
RUN cd /opt && \
    tar -xzf zookeeper-3.4.14.tar.gz && \
    mv zookeeper-3.4.14 ${ZOOKEEPER_HOME} && \
    rm /opt/zookeeper-3.4.14.tar.gz && \
    cp /tmp/configuration.cfg ${ZOOKEEPER_HOME}/conf/zoo.cfg && \
    mkdir -p /data/zookeeper && mkdir -p /datalog/zookeeper && mkdir /sasl/

# Support for kerberos
COPY ./krb5.conf ${ZOOKEEPER_HOME}/conf/krb5.conf

EXPOSE 2181 2888 3888

HEALTHCHECK --interval=60s --timeout=20s --start-period=25s --retries=2 CMD [ "healthcheck.sh" ]

ENV ZOOKEEPER_DATA_HOME=/data/zookeeper
ENV ZOOKEEPER_LOGS_HOME=/datalog/zookeeper
ENV ZOOKEEPER_SASL_HOME=/sasl

VOLUME [ "${ZOOKEEPER_DATA_HOME}", "${ZOOKEEPER_LOGS_HOME}" ]

WORKDIR ${ZOOKEEPER_HOME}

CMD ["start.sh"]