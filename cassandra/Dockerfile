FROM cassandra:3.11

# fix UTF-8 accents in init scripts
ENV LANG C.UTF-8

# install wget
RUN apt update && apt install -y wget

# setup prometheus javaagent, see https://www.robustperception.io/monitoring-cassandra-with-prometheus
RUN mkdir /opt/jmx \
    && cd /opt/jmx \
    && wget https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.3.0/jmx_prometheus_javaagent-0.3.0.jar \
    # && wget https://raw.githubusercontent.com/prometheus/jmx_exporter/master/example_configs/cassandra.yml \
    && echo 'JVM_OPTS="$JVM_OPTS -javaagent:'$PWD/jmx_prometheus_javaagent-0.3.0.jar=7070:$PWD/cassandra.yml'"' >> /etc/cassandra/cassandra-env.sh

COPY prometheus_cassandra.yml /opt/jmx/cassandra.yml

# add scripts to initialize the db
COPY schema.cql /docker-entrypoint-initdb.d/01.cql

COPY entrypoint.sh /

EXPOSE 9042 7070

ENTRYPOINT ["/entrypoint.sh"]
CMD ["cassandra", "-f"]