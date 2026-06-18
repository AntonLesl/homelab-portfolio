#!/bin/bash
# Install Wazuh agent on Linux VM and point to manager
# Usage: WAZUH_MANAGER=192.168.30.20 AGENT_NAME=kali bash wazuh-agent-install-linux.sh

MANAGER=${WAZUH_MANAGER:-"192.168.30.20"}
NAME=${AGENT_NAME:-"$(hostname)"}

curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add -
echo "deb https://packages.wazuh.com/4.x/apt/ stable main" \
  | tee /etc/apt/sources.list.d/wazuh.list
apt update

WAZUH_MANAGER="$MANAGER" WAZUH_AGENT_NAME="$NAME" apt install -y wazuh-agent

systemctl enable --now wazuh-agent
echo "Wazuh agent installed. Manager: $MANAGER | Agent name: $NAME"
/var/ossec/bin/agent_control -l
