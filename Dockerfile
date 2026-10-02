FROM apache/apisix:3.15.0-ubuntu

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    geoip-bin \
    libgeoip-dev \
    libgeoip1 \
    && rm -rf /var/lib/apt/lists/*

USER apisix
