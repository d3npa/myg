#!/bin/sh

# with help from claude lol
# sets up a wi-fi network (WEP; key in hostapd.conf) and nftables rules

CONF_DIR="$(dirname "$0")"
UDEV_RULES="/etc/udev/rules.d/70-persistent-net.rules"

nft_start() {
    nft add chain global ds_wifi_input
    nft add chain global ds_wifi_forward

    nft add rule global ds_wifi_input udp dport 67 accept
    nft add rule global ds_wifi_input udp dport 53 accept
    nft add rule global ds_wifi_input tcp dport 53 accept
    nft add rule global ds_wifi_input tcp dport 80 accept
    nft add rule global ds_wifi_input tcp dport 443 accept
    nft add rule global ds_wifi_input tcp dport '{ 27500, 28910, 29900, 29901, 29920 }' accept
    nft add rule global ds_wifi_input udp dport '{ 27900, 27901 }' accept
    nft add rule global ds_wifi_input ct state established,related accept
    nft add rule global ds_wifi_input drop

    nft insert rule global ds_wifi_forward ct status dnat accept
    nft add rule global ds_wifi_forward drop

    nft insert rule global input iifname dswifi0 jump ds_wifi_input
    nft insert rule global forward iifname dswifi0 jump ds_wifi_forward
    nft insert rule global output oifname dswifi0 accept
}

nft_stop() {
    for handle in $(nft -a list chain global input 2>/dev/null | grep 'dswifi0' | awk '{print $NF}'); do
        nft delete rule global input handle $handle
    done
    for handle in $(nft -a list chain global forward 2>/dev/null | grep 'dswifi0' | awk '{print $NF}'); do
        nft delete rule global forward handle $handle
    done
    for handle in $(nft -a list chain global output 2>/dev/null | grep 'dswifi0' | awk '{print $NF}'); do
        nft delete rule global output handle $handle
    done

    nft flush chain global ds_wifi_input 2>/dev/null
    nft flush chain global ds_wifi_forward 2>/dev/null
    nft delete chain global ds_wifi_input 2>/dev/null
    nft delete chain global ds_wifi_forward 2>/dev/null
}

case "$1" in
  start)
    echo "Creating virtual AP interface dswifi0..."
    iw dev wlan0 interface add dswifi0 type __ap
    sleep 1
    ip link set dswifi0 up

    echo "Starting hostapd..."
    hostapd -B "${CONF_DIR}/hostapd.conf"
    sleep 1

    echo "Configuring interface..."
    ip addr add 192.168.33.1/24 dev dswifi0
    ip link set dswifi0 up

    echo "Injecting nftables rules..."
    nft_start

    echo "Starting dnsmasq..."
    dnsmasq --conf-file="${CONF_DIR}/dnsmasq-ds.conf"

    echo "Done. SSID: DS_WiFi on dswifi0"
    ;;
  stop)
    echo "Stopping DS WiFi AP..."
    killall hostapd 2>/dev/null
    killall dnsmasq 2>/dev/null

    echo "Removing nftables rules..."
    nft_stop

    ip link set dswifi0 down 2>/dev/null
    iw dev dswifi0 del 2>/dev/null

    echo "Done."
    ;;
  *)
    echo "Usage: $0 {start|stop}"
    exit 1
    ;;
esac
