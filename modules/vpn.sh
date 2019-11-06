#!/bin/sh

echo '# VPN MODULE'

echo 'Installing wireguard package...'
opkg install wireguard > /dev/null

echo 'Configuring wireguard...'
uci set network.wg0=interface
uci set network.wg0.private_key="${WIREGUARD_CLIENT_PRIVATE_KEY}"
uci add_list network.wg0.addresses='10.0.0.2/32'
uci set network.wg0.listen_port='51820'
uci set network.wg0.proto='wireguard'

uci add network wireguard_wg0 > /dev/null
uci set network.@wireguard_wg0[-1].public_key="${WIREGUARD_SERVER_PUBLIC_KEY}"
uci set network.@wireguard_wg0[-1].allowed_ips='0.0.0.0/0'
uci set network.@wireguard_wg0[-1].route_allowed_ips='0'
uci set network.@wireguard_wg0[-1].endpoint_host="${WIREGUARD_SERVER_HOST}"
uci set network.@wireguard_wg0[-1].endpoint_port='51820'
uci set network.@wireguard_wg0[-1].persistent_keepalive='25'

uci commit network

uci add firewall zone > /dev/null
uci set firewall.@zone[-1].name='wg'
uci set firewall.@zone[-1].family='ipv4'
uci set firewall.@zone[-1].masq='1'
uci set firewall.@zone[-1].output='ACCEPT'
uci set firewall.@zone[-1].forward='REJECT'
uci set firewall.@zone[-1].input='REJECT'
uci set firewall.@zone[-1].mtu_fix='1'
uci set firewall.@zone[-1].network='wg0'

uci add firewall forwarding > /dev/null
uci set firewall.@forwarding[-1].src='lan'
uci set firewall.@forwarding[-1].dest='wg'

uci commit firewall

echo
