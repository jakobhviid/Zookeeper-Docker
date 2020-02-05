FROM ubuntu:18.04

RUN apt update && \
    apt install -y --no-install-recommends openjdk-8-jre-headless
    
# Copy necessary scripts + configuration
COPY scripts configuration.cfg /tmp/
RUN chmod +x /tmp/*.sh && \
    mv /tmp/*.sh /usr/bin && \
    rm -rf /tmp/*.sh

# Install Zookeeper
#ADD https://apache.org/dist/zookeeper/zookeeper-3.4.14/zookeeper-3.4.14.tar.gz /opt/
COPY zookeeper-3.4.14.tar.gz /opt/
RUN cd /opt && \
    tar -xzf zookeeper-3.4.14.tar.gz && \
    mv zookeeper-3.4.14 zookeeper && \
    rm /opt/zookeeper-3.4.14.tar.gz && \
    cp /tmp/configuration.cfg /opt/zookeeper/conf/zoo.cfg

EXPOSE 2181 2888 3888

HEALTHCHECK --interval=30s --timeout=20s --start-period=15s --retries=2 CMD [ "healthcheck.sh" ]

VOLUME [ "/data/zookeeper" ]

WORKDIR /opt/zookeeper

CMD ["start.sh"]