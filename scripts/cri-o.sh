#!/usr/bin/env bash

VERSION=1.28
SUBVERSION=$(echo $VERSION | awk -F'.' '{print $1"."$2}')
OS=xUbuntu_22.04

cat <<EOF | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:
stable.list
deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:
/stable/$OS/ /
EOF

cat <<EOF | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:
stable:cri-o:$VERSION.list
deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:
/stable:/cri-o:/$VERSION/$OS/ /
EOF

curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable: cri-o:/$VERSION/$OS/Release.key | sudo apt-key add -
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key add -

sudo apt-get update
sudo apt-get install cri-o cri-o-runc cri-tools -y

sudo systemctl daemon-reload
sudo systemctl enable crio --now