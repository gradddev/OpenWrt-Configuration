#!/bin/sh

source ./environment-variables.sh

restart_network() {
    echo 'Restarting network...'
    /etc/init.d/network restart > /dev/null
}

wait_internet() {
    echo 'Waiting internet connection...'
    while ! ping -c 1 -W 1 google.com &> /dev/null; do
        sleep 1
    done
}

./modules/pppoe.sh
./modules/wi-fi.sh

restart_network
wait_internet

echo 'Updating list of available packages...'
opkg update > /dev/null
echo

./modules/vpn.sh
./modules/dns-over-https.sh

restart_network
wait_internet
echo

./modules/bypass-lock.sh

restart_network
