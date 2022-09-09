#!/bin/bash
ACTION=$1
DEVBASE=$2
DEVICE="/dev/${DEVBASE}"
MOUNT_POINT=$(/bin/mount | /bin/grep ${DEVICE} | /usr/bin/awk '{ print $3 }')  # See if this drive is already mounted
case "${ACTION}" in
    add)
        if [[ -n ${MOUNT_POINT} ]]; then exit 1; fi          # Already mounted, exit
        eval $(/sbin/blkid -o udev ${DEVICE})                # Get info for this drive: $ID_FS_LABEL, $ID_FS_UUID, and $ID_FS_TYPE
        OPTS="rw,relatime"                                   # Global mount options
        if [[ ${ID_FS_TYPE} == "vfat" ]]; then OPTS+=",users,gid=100,umask=000,shortname=mixed,utf8=1,flush"; fi     # File system type specific mount options
        if ! /bin/mount -o ${OPTS} ${DEVICE} /media/; then exit 1; fi          # Error during mount process: cleanup mountpoint
        ;;
    remove)
        if [[ -n ${MOUNT_POINT} ]]; then /bin/umount -l ${DEVICE}; fi
        ;;
esac


FILE=config.gb
# Search for a GB config file
if test -f "/media/$FILE"; then
   while IFS="=" read -r key value; do
    case "$key" in
      "http_proxy") echo "$key=$value";;
      "https_proxy") echo "$key=$value";;
      "no_proxy") echo "$key=$value";;
    esac
  done < /media/$FILE
fi

. /media/$FILE

MANIFESTS_DIR=/var/lib/rancher/k3s/server/manifests
EDGE_OPERATOR_SECRET="gbear-edge-operator-env"

sudo mkdir -p $MANIFESTS_DIR
sudo chmod 700 $MANIFESTS_DIR

if [ -n "$https_proxy" ]; then
    proxy_settings="  http_proxy: $(echo -n "$http_proxy" | base64 -w0)
  https_proxy: $(echo -n "$https_proxy" | base64 -w0)
  no_proxy: $(echo -n "$no_proxy" | base64 -w0)"
fi

sudo tee $MANIFESTS_DIR/gbear-edge-env.yaml > /dev/null << EOF
apiVersion: v1
kind: Namespace
metadata:
  name: gbear
---
apiVersion: v1
kind: Secret
metadata:
  namespace: gbear
  name: $EDGE_OPERATOR_SECRET
data:
  NODEMANAGER_TOKEN: $(echo -n $API_TOKEN | base64 -w0)
  NODEMANAGER_URL: $(echo -n $API_URL | base64 -w0)
  CLUSTER_ID: $(echo -n $CLUSTER_ID | base64 -w0)
  NODEMANAGER_TENANT_ID: $(echo -n $TENANT_ID | base64 -w0)
$proxy_settings
EOF
# Dump logs to drive
logdate=$(hostname)-$(date "+%F%H%M%S")
logfile=journal-$logdate
journalctl -x --no-pager > /tmp/$logfile && gzip /tmp/$logfile && mv -v /tmp/$logfile.gz /media
tar zcvf /media/gbear-agent-states-$logdate.tgz /var/lib/gbear
kubectl get all -A -owide > /tmp/kubectl-$logdate && gzip /tmp/kubectl-$logdate && mv -v /tmp/kubectl-$logdate.gz /media
