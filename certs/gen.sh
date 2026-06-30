#!/bin/sh -e

CERT_URL="https://archive.org/download/NintendoHTTPScerts/cert.tar.xz"
P12_FILE="WII_NWC_1_CERT.p12"

# download certs
if [ ! -f "$P12_FILE" ]; then
    if which wget 2>/dev/null; then
        wget -q -O cert.tar.xz "$CERT_URL"
    elif which curl 2>/dev/null; then
        curl -sL -o cert.tar.xz "$CERT_URL"
    else
        echo "[!] error: wget or curl must be installed"
        exit 1
    fi

    tar xf cert.tar.xz cert/"$P12_FILE" --strip-components=1
    rm cert.tar.xz
fi

# extract cert and key from p12
openssl pkcs12 -in "$P12_FILE" -passin "pass:alpine" -legacy -nokeys \
    -out nwc.crt
openssl pkcs12 -in "$P12_FILE" -passin "pass:alpine" -legacy -nocerts -nodes \
    -out nwc.key

# gen a tls key pair for nginx. nds can only accept (up to?) 1024-bit keys
openssl genrsa -out server.key 1024 2>/dev/null

# just do wildcard lol
openssl req -new -key server.key -out server.csr -subj "/CN=*.*.*"
openssl x509 -req -in server.csr -CA nwc.crt -CAkey nwc.key \
    -CAcreateserial -out server.crt -days 3650 -sha1
cat server.crt nwc.crt > server.chain.crt

# cleanup
rm server.csr nwc.srl

echo "[*] created 'server.chain.crt' and 'server.key'"

