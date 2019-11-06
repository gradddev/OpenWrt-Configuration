#!/bin/sh

echo '# WI-FI MODULE'

echo 'Configuring Wi-Fi...'
uci set wireless.radio0.channel='6'
uci set wireless.radio0.country='RU'
uci set wireless.radio0.legacy_rates='0'
uci set wireless.radio0.noscan='1'
uci del wireless.radio0.disabled &> /dev/null
uci set wireless.default_radio0.ssid="${WIFI_2G_SSID}"
uci set wireless.default_radio0.encryption='psk2'
uci set wireless.default_radio0.key="${WIFI_2G_PASSWORD}"

uci set wireless.radio1.channel='64'
uci set wireless.radio1.country='RU'
uci set wireless.radio1.legacy_rates='0'
uci set wireless.radio1.noscan='1'
uci del wireless.radio1.disabled &> /dev/null
uci set wireless.default_radio1.ssid="${WIFI_5G_SSID}"
uci set wireless.default_radio1.encryption='psk2'
uci set wireless.default_radio1.key="${WIFI_5G_PASSWORD}"

uci commit wireless

echo
