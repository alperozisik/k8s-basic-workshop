# Creating cluster

## Initialize cluster
We are going to create a single master node K8s cluster. Execute the following script to init the cluster via kubeadm:
```shell
sudo kubeadm init --pod-network-cidr 192.168.0.0/16 --service-cidr 10.96.0.0/16 --apiserver-advertise-address $(ifconfig ens3 | grep "inet " | awk '{print $2}') --cri-socket unix:///var/run/cri-dockerd.sock
```
Let's break down some of the arguments:
- `--pod-network-cidr` network of the pods. This is optional and the value provided by our picking
- `--service-cidr` network of the k8s internal services. This is optional and the value provided by our picking
- `--apiserver-advertise-address` Private IP address of the master node. This IP should  be accessible by other nodes in the same cluster. This is required. `$(ifconfig ens3 | grep "inet " | awk '{print $2}')` automatically getting the IP address from the network interface.
- `--cri-socket` which container runtime that we are going to use. Documentation says optional. By experince, it is best to be provided.

Fore more information please check official documentation: [Creating a cluster with kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)

## Post init

## Install network plugin
Networking of pods, nodes are not part of the k8s. It is handled by the network plugin. Here are some popular network plugins. You can use **flannel** or **calico** as desired
- **calico:** This is very popular
- **flannel:** This is favored by Oracle Cloud
- Official documentation
    - [Network Plugins](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/)
    - [Container Network Interface (CNI) - networking for Linux containers](https://github.com/containernetworking/cni)