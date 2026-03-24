local mystery gift server.
partly claude-coded.

== REVIEW before using ==

sources:

- certs/gen.sh
- dwc/Dockerfile
- nginx/Dockerfile (builds openssl & nginx for SSL3 support)


configs:

- dwc/adminpageconf.json (admin panel passwd if you need it)
- wifi/dnsmasq-ds.conf (set upstream DNS)
- wifi/hostapd.conf (wep keys)

note: wifi subnet is 192.168.33.0/24. hardcoded everywhere in wifi/* ...sry xD


== USAGE ==

# gen keys (once)

cd certs
./gen.sh
cd ..


# run dwc server (add -d to detach; basic docker stuff)

docker compose up


# wi-fi ap (assumes nftables. see wifi/readme.txt)

cd wifi
./ds-wifi start
./ds-wifi stop


== RESOURCES ==

- https://github.com/barronwaffles/dwc_network_server_emulator
- tls trix: https://github.com/KaeruTeam/nds-constraint


