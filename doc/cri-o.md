export VERSION=1.28
export SUBVERSION=$(echo $VERSION | awk -F'.' '{print $1"."$2}')
export OS=xUbuntu_22.04

echo "deb [signed-by=/usr/share/keyrings/libcontainers-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb [signed-by=/usr/share/keyrings/libcontainers-crio-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list

mkdir -p /usr/share/keyrings
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | gpg --dearmor -o /usr/share/keyrings/libcontainers-archive-keyring.gpg
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/Release.key | gpg --dearmor -o /usr/share/keyrings/libcontainers-crio-archive-keyring.gpg

sudo systemctl daemon-reload
sudo systemctl enable crio
sudo systemctl start crio

apt-get update
apt-get install cri-o cri-o-runc -y

sudo swapoff -a
sudo apt install net-tools -y

sudo systemctl stop ufw
sudo systemctl disable ufw

sudo kubeadm init --pod-network-cidr 192.168.0.0/16 --service-cidr 10.96.0.0/16 --apiserver-advertise-address $(ifconfig ens3 | grep "inet " | awk '{print $2}') --cri-socket unix:///var/run/crio/crio.sock

kubeadm init --pod-network-cidr 192.168.0.0/16 --service-cidr 10.96.0.0/16 --apiserver-advertise-address 10.6.0.65 --cri-socket unix:///var/run/crio/crio.sock

