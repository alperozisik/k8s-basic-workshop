#!/usr/bin/env bash

wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.13/cri-dockerd_0.3.13.3-0.ubuntu-jammy_amd64.deb
sudo dpkg -i ./cri-dockerd_0.3.13.3-0.ubuntu-jammy_amd64.deb
sudo apt-get install -f
rm ./cri-dockerd_0.3.13.3-0.ubuntu-jammy_amd64.deb