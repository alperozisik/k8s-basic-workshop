sudo kubeadm init --pod-network-cidr 192.168.0.0/16 --service-cidr 10.96.0.0/16 --apiserver-advertise-address $(ifconfig ens3 | grep "inet " | awk '{print $2}') --cri-socket unix:///var/run/cri-dockerd.sock

sudo kubeadm init --apiserver-advertise-address=$IPADDR \
    --apiserver-cert-extra-sans=$IPADDR  \
    --pod-network-cidr=$POD_CIDR \
    --node-name $NODENAME \
    --ignore-preflight-errors Swap

$(ip route get 8.8.8.8 | sed -n 's/.*src \([^\ ]*\).*/\1/p')


sudo kubeadm init --pod-network-cidr 192.168.0.0/16 --service-cidr 10.96.0.0/16 --apiserver-advertise-address 10.6.0.62 --apiserver-cert-extra-sans=10.6.0.62,130.61.21.136 --cri-socket unix:///var/run/cri-dockerd.sock

sudo kubeadm init --pod-network-cidr 192.168.0.0/16 --service-cidr 10.96.0.0/16 --apiserver-advertise-address 10.6.0.62 --apiserver-cert-extra-sans=10.6.0.62,130.61.21.136 --cri-socket unix:///var/run/crio/crio.sock

sudo kubeadm join 10.6.0.62:6443 --token ssg6rw.kegxp47iwvugcfac \
        --discovery-token-ca-cert-hash sha256:9a9212ee4efc3bc7f2159f2c0f4520de6c07b81322f7da2b0a7920ea61bbccbb  --cri-socket unix:///var/run/crio/crio.sock


kubectl delete node k8s-worker-g2
kubectl delete node k8s-worker-g1

kubectl delete -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/custom-resources.yaml
kubectl delete -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml
sudo kubeadm reset -f --cri-socket unix:///var/run/cri-dockerd.sock

helm uninstall flannel --namespace kube-flannel
sudo kubeadm reset -f --cri-socket unix:///var/run/crio/crio.sock

sudo rm -rf /etc/kubernetes/ && sudo rm -rf /etc/cni/net.d && rm -rf $HOME/.kube



sudo iptables -F
sudo iptables -X
sudo iptables -t nat -F
sudo iptables -t nat -X
sudo iptables -t mangle -F
sudo iptables -t mangle -X
sudo iptables -t raw -F
sudo iptables -t raw -X
sudo iptables-save | sudo tee /etc/iptables/rules.v4



curl https://raw.githubusercontent.com/alperozisik/k8s-basic-workshop/main/scripts/cri-o.sh | bash


#!/usr/bin/env bash

export VERSION=1.28
export SUBVERSION=$(echo $VERSION | awk -F'.' '{print $1"."$2}')
export OS=xUbuntu_22.04

cat <<EOF | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /
EOF

cat <<EOF | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list
deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /
EOF

curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:cri-o:/$VERSION/$OS/Release.key | sudo apt-key add -
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key add -

sudo apt-get update
sudo apt-get install cri-o cri-o-runc cri-tools -y

sudo systemctl daemon-reload
sudo systemctl enable crio --now


sudo systemctl stop kubelet
sudo systemctl stop kube-apiserver
sudo systemctl stop kube-controller-manager
sudo systemctl stop kube-scheduler
sudo systemctl restart crio
sudo systemctl start kubelet
sudo systemctl start kube-apiserver --runtime=remote --remote="cri-o"
sudo systemctl start kube-controller-manager --runtime=remote --remote="cri-o"
sudo systemctl start kube-scheduler --runtime=remote --remote="cri-o"