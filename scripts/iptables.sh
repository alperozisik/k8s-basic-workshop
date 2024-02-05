#!/usr/bin/env bash

sudo ufw disable
sudo apt-get update
sudo apt-get install iptables-persistent
sudo systemctl stop ufw
sudo systemctl disable ufw
sudo systemctl start iptables-persistent
sudo systemctl enable iptables-persistent

sudo iptables -A INPUT -p tcp --dport 6443 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 2379:2380 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 10250 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 10255 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 179 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 10259 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 10257 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 30000:32767 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 8285 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 8472 -j ACCEPT
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