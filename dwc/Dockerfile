FROM python:2.7-slim

RUN sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list && \
    sed -i 's|http://security.debian.org|http://archive.debian.org|g' /etc/apt/sources.list && \
    sed -i '/buster-updates/d' /etc/apt/sources.list && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends git gcc && \
    pip install twisted && \
    apt-get purge -y gcc && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/barronwaffles/dwc_network_server_emulator.git /dwc && \
    sed -i 's/127.0.0.1/0.0.0.0/g' /dwc/altwfc.cfg && \
    sed -i 's?gpcm.db?./data/gpcm.db?g' /dwc/gamespy/gs_database.py && \
    sed -i 's?storage.db?./data/storage.db?g' /dwc/storage_server.py && \
    mkdir -p /dwc/data

WORKDIR /dwc
VOLUME /dwc/data

EXPOSE 8000 9000 9001 9002 9003 27500 28910 29900 29901 29920 27900/udp 27901/udp

CMD ["python", "master_server.py"]

