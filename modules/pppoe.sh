#!/bin/sh

echo '# PPPoE MODULE'

echo 'Configuring PPPoE...'
uci del network.wan.proto &> /dev/null
uci set network.wan.proto='pppoe'
uci set network.wan.username="${PPPOE_USERNAME}"
uci set network.wan.password="${PPPOE_PASSWORD}"
uci commit network

echo
