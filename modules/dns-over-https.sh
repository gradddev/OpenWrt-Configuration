#!/bin/sh

echo '# DNS-Over-HTTPS MODULE'

echo 'Remove dnsmasq and odhcpd-ipv6only packages...'
opkg remove dnsmasq odhcpd-ipv6only > /dev/null
dhcp_config=$(mktemp)
mv /etc/config/dhcp $dhcp_config


echo 'Installing dnsmasq-full and https_dns_proxy packages...'
opkg install dnsmasq-full https_dns_proxy > /dev/null
mv $dhcp_config /etc/config/dhcp


echo  'Configuring DNS-Over-HTTPS by Google...'
uci del dhcp.@dnsmasq[0].server &> /dev/null
uci add_list dhcp.@dnsmasq[0].server='127.0.0.1#5053'
uci set dhcp.@dnsmasq[0].noresolv='1'
uci commit dhcp

/etc/init.d/dnsmasq restart > /dev/null
/etc/init.d/https_dns_proxy restart > /dev/null

echo
