#!/bin/sh

#this script is based on https://hub.docker.com/r/itsdaspecialk/pia-openvpn/
echo "starting... " > debug.log

set -e -u -o pipefail

#activate_firewall based on code from dperson/openvpn-client
activate_firewall() {
  # the VPN Port
  local port=1197
  # the ip of the docker network
  local dock_net=$(ip -o addr show dev eth0 | 
                         awk '$3 == "inet" {print $4}')
  echo "dock_net found... ${dock_net}" >> debug.log
  # if the ovpn file exists, try to set the port from the file
  if [ -r "${CONNECTIONSTRENGTH}/${REGION}.ovpn" ]; then
    port=$(awk '/^remote / && NF ~ /^[0-9]*$/ {print $NF}' "${CONNECTIONSTRENGTH}/${REGION}.ovpn" |
           grep ^ || echo 1197)
	echo "Port found... ${port}" >> debug.log
  fi

  iptables -F OUTPUT
  iptables -P OUTPUT DROP
  iptables -A OUTPUT -o lo -j ACCEPT
  iptables -A OUTPUT -o tun+ -j ACCEPT
  iptables -A OUTPUT -d ${dock_net} -j ACCEPT
  iptables -A OUTPUT -p udp -m udp --dport 53 -j ACCEPT
  iptables -A OUTPUT -p tcp -m owner --gid-owner vpn -j ACCEPT 2>/dev/null &&
  iptables -A OUTPUT -p udp -m owner --gid-owner vpn -j ACCEPT || {
    iptables -A OUTPUT -p tcp -m tcp --dport $port -j ACCEPT
    iptables -A OUTPUT -p udp -m udp --dport $port -j ACCEPT;
  }
}

ARGS=

if [ -n "$REGION" ] && [ -n "$CONNECTIONSTRENGTH" ]; then
  REGION=`echo ${REGION// /_} | awk '{print tolower($0)}'`
  CONNECTIONSTRENGTH=`echo ${CONNECTIONSTRENGTH} | awk '{print tolower($0)}'`
  ARGS="${ARGS}--config \"${CONNECTIONSTRENGTH}/${REGION}.ovpn\""
fi

echo "connection args complete... " >> debug.log

if [ -n "${USERNAME:-""}" -a -n "${PASSWORD:-""}" ]; then
  echo "$USERNAME" > auth.conf
  echo "$PASSWORD" >> auth.conf
  chmod 600 auth.conf
  ARGS="$ARGS --auth-user-pass auth.conf"
fi

echo "auth args complete... " >> debug.log

for ARG in $@; do
  ARGS="$ARGS \"$ARG\""
done

activate_firewall
echo "activate firewall complete... " >> debug.log

mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
  mknod -m 0666 /dev/net/tun c 10 200
fi

echo "$ARGS" >> debug.log

exec sg vpn -c "openvpn $ARGS"