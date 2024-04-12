#!/bin/bash
# Name: ansible-env.sh
# Description: Initialization for ansible control node
# Author: Huangdaojin
# Date: 2024.1.7
# update: 2024.1.7
# Version: 0.0.1
# Usage: bash ansible-env.sh
# Applicable: Debian 12


# Install necessary packages for ansible running

apt update -y
apt upgrade -y 
apt install -y python3 ansible sshpass
apt autoremove -y

# Generate ssh key
ssh-keygen  -t rsa -b 2048 -f ~/.ssh/id_rsa -N "" 
# ssh-keygen  -t rsa -b 2048  -N "" 