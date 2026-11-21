ARG BASE_IMAGE=apache/apisix:3.21.0-debian

FROM ${BASE_IMAGE} AS geoip2-builder

USER root

ARG GEOIP2_MODULE_REF=cbaa35461c62a99d2577e6bae3273492502d8769
# APISIX Runtime 1.4.3 pairs OpenResty 1.31.8.1 with the NGINX 1.31.9 core.
ARG NGINX_SOURCE_VERSION=1.31.9
ARG NGINX_SOURCE_COMMIT=c2c44702c2fbc572e4cfb0a52331061d7fcaca16

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    git \
    libpcre3-dev \
    libssl-dev \
    libmaxminddb-dev \
    wget \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    mkdir -p /tmp/geoip2-build; \
    git clone https://github.com/leev/ngx_http_geoip2_module.git /tmp/geoip2-build/ngx_http_geoip2_module; \
    cd /tmp/geoip2-build/ngx_http_geoip2_module; \
    git checkout -q "${GEOIP2_MODULE_REF}"; \
    cd /tmp/geoip2-build; \
    git clone --depth 1 --branch "release-${NGINX_SOURCE_VERSION}" https://github.com/nginx/nginx.git "nginx-${NGINX_SOURCE_VERSION}"; \
    test "$(git -C "nginx-${NGINX_SOURCE_VERSION}" rev-parse HEAD)" = "${NGINX_SOURCE_COMMIT}"; \
    cd "nginx-${NGINX_SOURCE_VERSION}"; \
    auto/configure --with-compat --add-dynamic-module=/tmp/geoip2-build/ngx_http_geoip2_module; \
    make -j"$(nproc)" modules; \
    MODULE_SO_PATH="$(find objs -type f -name ngx_http_geoip2_module.so -print -quit)"; \
    test -n "${MODULE_SO_PATH}"; \
    install -D -m 0644 "${MODULE_SO_PATH}" /tmp/ngx_http_geoip2_module.so

FROM ${BASE_IMAGE}

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    libmaxminddb0 \
    mmdb-bin \
    && rm -rf /var/lib/apt/lists/* \
    && install -d /usr/local/openresty/nginx/modules

COPY --from=geoip2-builder /tmp/ngx_http_geoip2_module.so /usr/local/openresty/nginx/modules/ngx_http_geoip2_module.so

USER apisix

# Fail the build if the dynamic module is incompatible with the actual runtime.
RUN printf '%s\n' \
    'load_module /usr/local/openresty/nginx/modules/ngx_http_geoip2_module.so;' \
    'error_log stderr;' \
    'pid /tmp/geoip2-test.pid;' \
    'events {}' \
    'http { access_log off; }' > /tmp/geoip2-test.conf \
    && openresty -t -p /tmp/ -c /tmp/geoip2-test.conf \
    && rm /tmp/geoip2-test.conf
