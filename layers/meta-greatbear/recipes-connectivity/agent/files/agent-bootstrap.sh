#!/bin/sh

set -ex

LOG_LEVEL="debug"
SB_API="https://nmngr-api.dev.gbear.scratch.eticloud.io/api/v1"

if [ -z "$API_KEY" ]; then
    API_KEY="vXtdRRCo4xE4A3"
fi

if [ -z "$HARDWARE_ID" ]; then
    HARDWARE_ID=$(tr -d '\0' </proc/device-tree/serial-number)
fi

if [ -z "$PLATFORM" ]; then
    PLATFORM="gbeos"
fi

hostnamectl set-hostname gb-$HARDWARE_ID
sed -i "s/^127.0.1.1.*/127.0.1.1 gb-$HARDWARE_ID/" /etc/hosts

wsdir=/var/lib/gbear
mkdir -p $wsdir

tee /etc/systemd/system/agent.service.env >/dev/null <<END
NODE_HARDWAREID=$HARDWARE_ID
NODEMANAGER_URL=$SB_API
NODEMANAGER_TOKEN=$API_KEY
NODE_PLATFORM=$PLATFORM
LOG_LEVEL=$LOG_LEVEL
AGENT_DATA_DIR=$wsdir
END

FILE=config.gb
# Search for a GB config file
if test -f "/media/$FILE"; then
   while IFS="=" read -r key value; do
    case "$key" in
      "http_proxy") export http_proxy="$value";;
      "https_proxy") export https_proxy="$value";;
      "no_proxy") export no_proxy="$value";;
    esac
  done < /media/$FILE
fi

if [ -n "$http_proxy$https_proxy" ]; then
    tee -a /etc/systemd/system/agent.service.env << EOF
http_proxy=$http_proxy
https_proxy=$https_proxy
no_proxy=$no_proxy
EOF
fi

