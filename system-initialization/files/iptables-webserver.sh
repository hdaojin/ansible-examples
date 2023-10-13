#!/bin/bash
# Copyright (c) 2021, Huang Daojin
# All rights reserved.
# Name: iptables-webserver.sh
# Author: Huang Daojin
# Date: 2022-01-03
# Update: 2023.10.12
# Version: 1.0.1
# Description: This script is used to set iptables rules for webserver.
# Usage: ./iptables-webserver.sh
# Apply: RHEL/CentOS/Rocky 8 or Debian 12

Version="1.0.1"

# Set some variables
unset LANG
export LANG=en_US.UTF-8
ipts=/sbin/iptables
default_ssh_port=1019
http_port=80
https_port=443
#mod=/sbin/modprobe

# judge if root

if [ "$UID" -ne 0 ]; then
    echo "You must be root to run this script."
    exit 1
fi

usage() {
    cat <<EOF
    Usage: $(basename $0) [OPTION]...
    Set iptables rules for webserver.

    -h        Display this help and exit.
    -v        Output version information and exit.
    -p        Set ssh port.
EOF
}

while getopts 'hvp:' arg; do
    case $arg in
    h)
        usage
        exit 0
        ;;
    v)
        echo "$(basename $0) version: $Version"
        exit 0
        ;;
    p)
        ssh_port=$OPTARG
        ;;
    ?)
        usage
        exit 1
        ;;
    esac
done

if [ "$ssh_port" -lt 1 -o "$ssh_port" -gt 65535 ]; then
    echo "The ssh port must be between 1 and 65535."
    exit 1
fi

if [ -z "$ssh_port" ]; then
    ssh_port=$default_ssh_port
fi

# judge if RHEL or Debian

if [ -f /etc/redhat-release ]; then
    os_release="RHEL"
elif [ -f /etc/debian_version ]; then
    os_release="Debian"
else
    echo "This script is only for RHEL or Debian."
    exit 1
fi

# Check and install iptables-services if not exist

if [ "$os_release" == "RHEL" ]; then
    rpm -q iptables-services >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        dnf -y install iptables-services
    fi
elif [ "$os_release" == "Debian" ]; then
    dpkg -s iptables-persistent &>/dev/null
    if [ $? -ne 0 ]; then
        apt -y install iptables-persistent
    fi
fi

# Disable other firewall services
for service in firewalld ip6tables nftables; do
    systemctl stop $service &>/dev/null
    systemctl disable $service &>/dev/null
done

systemctl start iptables
systemctl enable iptables

# Flush all rules
echo "[+] Flush all rules..."
$ipts -F
$ipts -t nat -F
$ipts -X

# Set web server rules
# Drop all packets that are INVALID
echo "[+] Set web server rules..."
$ipts -A INPUT -m state --state INVALID -j DROP
$ipts -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
$ipts -A INPUT -p tcp -m multiport --dports $http_port,$https_port -m state --state NEW -j ACCEPT
$ipts -A INPUT -i lo -j ACCEPT
# Drop ssh connection if retry more than 5 times in 10 minutes
$ipts -A INPUT -p tcp --dport $ssh_port -m state --state NEW -m recent --name ssh --update --seconds 600 --hitcount 5 -j DROP
$ipts -A INPUT -p tcp --dport $ssh_port -m state --state NEW -m recent --name ssh --set -j ACCEPT
# $ipts -A INPUT -p tcp --dport $ssh_port -m state --state NEW -m recent --name ssh --set
# $ipts -A INPUT -p tcp --dport $ssh_port -m state --state NEW -j ACCEPT
# Drop all other packets
$ipts -A INPUT -j REJECT --reject-with icmp-host-prohibited
$ipts -A FORWARD -j REJECT --reject-with icmp-host-prohibited

# if you want to ping this server, you can use the following rules
# $ipts -I INPUT 3 -p icmp --icmp-type 8 -j ACCEPT

# Save rules
echo "[+] Save rules..."
if [ "$os_release" == "RHEL" ]; then
    service iptables save
elif [ "$os_release" == "Debian" ]; then
    iptables-save >/etc/iptables/rules.v4
fi