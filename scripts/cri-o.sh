#!/usr/bin/env bash

sudo apt install jq -y
curl https://raw.githubusercontent.com/cri-o/packaging/main/get | sudo bash

sudo systemctl daemon-reload
sudo systemctl enable crio --now