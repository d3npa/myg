local mystery gift server.
partly claude-coded.

this repo contains scaffolding for existing projects. see RESOURCES below

== SECURITY ==

this repo lets you set up a wi-fi ap with wep encryption from your linux box. consider the implications carefully. it's probably best to turn it off when not in use. passwords are hard-coded; see REVIEW/configs section below.


== REVIEW before using ==

sources:

- certs/gen.sh
- dwc/Dockerfile
- nginx/Dockerfile (builds openssl & nginx for SSL3 support)


configs:

- wifi/dnsmasq-ds.conf (set upstream DNS)
- wifi/hostapd.conf (wep keys; default: 'mydspassword!')
- dwc/adminpageconf.json (admin panel passwd if you need it; 'mydspassword!')

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


