ARG TARGETARCH

FROM cassandra:3.11 AS base_amd64

FROM cassandra:3.11 AS base_arm64

FROM cassandra:3.11 AS base_ppc64le

FROM ibmcom/apachecassandra-s390x:3.11.3 AS base_s390x

FROM base_$TARGETARCH AS final

COPY schema/* /cassandra-schema/

ENV CQLSH_HOST=cassandra
ENTRYPOINT ["/cassandra-schema/docker.sh"]