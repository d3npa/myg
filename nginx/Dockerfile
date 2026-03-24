FROM debian:bookworm-slim AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential wget libpcre3-dev zlib1g-dev ca-certificates perl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Build OpenSSL 1.1.1w separately with SSLv3 and RC4 enabled
RUN wget -q https://github.com/openssl/openssl/releases/download/OpenSSL_1_1_1w/openssl-1.1.1w.tar.gz && \
    tar xzf openssl-1.1.1w.tar.gz && rm openssl-1.1.1w.tar.gz && \
    cd openssl-1.1.1w && \
    ./config --prefix=/opt/openssl --openssldir=/opt/openssl \
        shared enable-ssl3 enable-ssl3-method enable-weak-ssl-ciphers && \
    make -j$(nproc) && make install_sw

# Verify RC4 and SSLv3 actually work
RUN LD_LIBRARY_PATH=/opt/openssl/lib /opt/openssl/bin/openssl ciphers RC4-SHA:RC4-MD5 && \
    echo "RC4 ciphers: OK" && \
    LD_LIBRARY_PATH=/opt/openssl/lib /opt/openssl/bin/openssl s_client -help 2>&1 | grep -q ssl3 && \
    echo "SSLv3 support: OK"

# Build nginx against custom OpenSSL
RUN wget -q https://nginx.org/download/nginx-1.20.2.tar.gz && \
    tar xzf nginx-1.20.2.tar.gz && rm nginx-1.20.2.tar.gz && \
    cd nginx-1.20.2 && \
    ./configure \
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/dev/stderr \
        --http-log-path=/dev/stdout \
        --with-http_ssl_module \
        --without-http_gzip_module \
        --with-cc-opt="-I/opt/openssl/include" \
        --with-ld-opt="-L/opt/openssl/lib -Wl,-rpath,/opt/openssl/lib" && \
    make -j$(nproc) && make install

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends libpcre3 && \
    rm -rf /var/lib/apt/lists/*
COPY --from=build /usr/sbin/nginx /usr/sbin/nginx
COPY --from=build /etc/nginx /etc/nginx
COPY --from=build /opt/openssl/lib /opt/openssl/lib

CMD ["nginx", "-g", "daemon off;"]
