ARG BASE_IMAGE=docker.io/library/ubuntu:24.04
FROM ${BASE_IMAGE}

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        debhelper \
        devscripts \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/local/bin/build-source
ENTRYPOINT ["/usr/local/bin/build-source"]
