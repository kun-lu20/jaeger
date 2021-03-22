ARG TARGETARCH

FROM cassandra:3.11 AS base-amd64

FROM cassandra:3.11 AS base-arm64

FROM cassandra:3.11 AS base-ppc64le

FROM ibmcom/apachecassandra-s390x:3.11.3 AS base-s390x

FROM base-${TARGETARCH} AS final

COPY schema/* /cassandra-schema/

ENV CQLSH_HOST=cassandra
ENTRYPOINT ["/cassandra-schema/docker.sh"]