wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.9/cri-dockerd_0.3.9.3-0.ubuntu-jammy_amd64.deb
sudo dpkg -i /home/ubuntu/cri-dockerd_0.3.9.3-0.ubuntu-jammy_amd64.deb
sudo apt-get install -f
rm ./cri-dockerd_0.3.9.3-0.ubuntu-jammy_amd64.deb