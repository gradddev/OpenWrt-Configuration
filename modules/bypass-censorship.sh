#!/bin/sh

echo '# BYPASS-CENSORSHIP MODULE'

echo 'Installing ipset and curl packages...'
opkg install ipset curl > /dev/null

echo 'Configuring bypass censorship...'
cat > /usr/bin/update-prefixes << \EOM
#!/bin/sh

if ! ipset list -n | grep -q 'prefixes'; then
	ipset create 'prefixes' hash:net
fi

ipset destroy temporary-prefixes -q
prefixes=$(mktemp 'prefixes.XXXXXX')
echo 'create temporary-prefixes hash:net' \
		'family inet' \
		> "$prefixes"
curl --silent https://antifilter.download/list/allyouneed.lst | \
	xargs -n1 echo 'add temporary-prefixes ' >> "$prefixes"
ipset restore < "$prefixes"
rm -f "$prefixes"

number_of_prefixes=$(
	ipset list temporary-prefixes | \
		grep 'Number of entries' | \
		awk -F ': ' '{print $NF}'
)
if [[ -z $number_of_prefixes || $number_of_prefixes -eq '0' ]]; then
	exit 1
fi

ipset swap temporary-prefixes prefixes
EOM

cat > /etc/init.d/update-prefixes << \EOM
#!/bin/sh /etc/rc.common

USE_PROCD=1
START=99

start_service() {
	procd_open_instance
	procd_set_param command /bin/sh '/usr/bin/update-prefixes'
	procd_set_param stdout 1
	procd_set_param stderr 1
	procd_close_instance
}
EOM
chmod +x /etc/init.d/update-prefixes
/etc/init.d/update-prefixes enable
/etc/init.d/update-prefixes start

echo '*/5 * * * * /etc/init.d/update-prefixes start' >> /etc/crontabs/root
echo >> /etc/crontabs/root
/etc/init.d/cron enable
/etc/init.d/cron start

echo '99  prefixes' >> /etc/iproute2/rt_tables
cat > /etc/hotplug.d/iface/30-add-route << \EOM
#!/bin/sh
ip route add table prefixes default dev wg0
EOM

uci add network rule > /dev/null
uci set network.@rule[-1].priority='100'
uci set network.@rule[-1].lookup='prefixes'
uci set network.@rule[-1].mark='0x1'

uci add firewall ipset > /dev/null
uci set firewall.@ipset[-1].name='prefixes'
uci set firewall.@ipset[-1].storage='hash'
uci set firewall.@ipset[-1].match='dst_net'

uci add firewall rule > /dev/null
uci set firewall.@rule[-1].src='lan'
uci set firewall.@rule[-1].proto='all'
uci set firewall.@rule[-1].ipset='prefixes'
uci set firewall.@rule[-1].set_mark='0x1'
uci set firewall.@rule[-1].target='MARK'

uci commit

echo
