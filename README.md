# OpenWrt Configuration

## Modules

- PPPoE
- Wi-Fi
- VPN
- DNS over HTTPS
- Bypass Lock

## How to use?

```bash
cp environment-variables.sh.example environment-variables.sh
# Set your own variables
nano environment-variables.sh
# Enable or disable modules you want
nano configure.sh
# Copy files to OpenWrt using SSH
scp -r . root@192.168.1.1:/tmp/config
# Connect to OpenWrt using SSH
ssh root@192.168.1.1
# Change directory to /tmp/config
cd /tmp/config
# Run
./configure.sh
```
