#!/usr/bin/env bash

### ufw is disabled by default via OCI Ubuntu image
# sudo ufw disable
# sudo systemctl stop ufw
# sudo systemctl disable ufw


### iptables-persistent is normally installed via OCI Ubuntu image
# sudo apt-get update
# sudo apt-get install iptables-persistent -y
# sudo systemctl start iptables-persistent
# sudo systemctl enable iptables-persistent


# Flush existing rules
sudo iptables -F

# Set default policy to ACCEPT
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT


################################################################################
#######Alternative open ports instead ##########################################
####   sudo iptables -A INPUT -p tcp --dport 6443 -j ACCEPT
####   sudo iptables -A INPUT -p tcp --dport 2379:2380 -j ACCEPT
####   sudo iptables -A INPUT -p tcp --dport 10250 -j ACCEPT
####   sudo iptables -A INPUT -p tcp --dport 10255 -j ACCEPT
####   sudo iptables -A INPUT -p tcp --dport 179 -j ACCEPT
####   sudo iptables -A INPUT -p tcp --dport 10259 -j ACCEPT
####   sudo iptables -A INPUT -p tcp --dport 10257 -j ACCEPT
####   sudo iptables -A INPUT -p tcp --dport 30000:32767 -j ACCEPT
####   sudo iptables -A INPUT -p udp --dport 8285 -j ACCEPT
####   sudo iptables -A INPUT -p udp --dport 8472 -j ACCEPT
####   sudo iptables -D INPUT -j REJECT --reject-with icmp-host-prohibited
####   sudo iptables -D FORWARD -j REJECT --reject-with icmp-host-prohibited
################################################################################


# Save new rules
sudo iptables-save | sudo tee /etc/iptables/rules.v4

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system