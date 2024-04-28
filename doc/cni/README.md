# Container Networking Interface (CNI)
In the Kubernetes world, CNI stands for Container Networking Interface. CNI is a standard interface for network plugins in container runtimes like Docker, containerd, and CRI-O. It defines how network plugins should be configured and interact with container runtimes to provide networking capabilities to containers.

CNI plugins are responsible for tasks such as setting up network namespaces, configuring network interfaces, managing IP addresses, and enabling communication between containers and external networks. They allow Kubernetes clusters to use various networking solutions, such as overlay networks, bridge networks, and software-defined networking (SDN) solutions, to meet different deployment requirements.

Overall, CNI plays a crucial role in enabling Kubernetes to manage networking for containerized applications efficiently and securely.


# List of CNI Plugins
You can find a list of network plugins compatible with Kubernetes on the official Kubernetes documentation website. Here's where you can find it:

1. **Kubernetes Documentation**: The Kubernetes documentation provides information on various network plugins, their features, and how to configure them. You can find it in the Networking section of the Kubernetes documentation: [Kubernetes Networking Plugins](https://kubernetes.io/docs/concepts/cluster-administration/networking/#how-to-choose-a-networking-solution)

2. **CNI GitHub Repository**: The Container Networking Interface (CNI) GitHub repository contains various network plugins that are compatible with Kubernetes. You can explore the repository to find plugins that suit your requirements: [CNI GitHub Repository](https://github.com/containernetworking/plugins)

3. **Third-Party Websites**: Some third-party websites also provide comparisons and lists of Kubernetes network plugins. However, always ensure that you refer to reliable sources for accurate information.

By referring to these resources, you can explore different network plugins and choose the one that best fits your Kubernetes cluster requirements.

# Working on cloud networks
Most of the cloud networks are Layer-3 (l3) network. (See [network layers](https://en.wikipedia.org/wiki/Network_layer)). Unless configured otherwise OCI VCN is a l3 network. The selected plugin should be in that format.

# Install network plugin
Networking of pods, nodes are not part of the k8s. It is handled by the network plugin. Here are some popular network plugins. You can use **flannel** or **calico** as desired
- **flannel:** This is favored by Oracle Cloud
- **calico:** This is very popular
- Official documentation
    - [Network Plugins](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/)
    - [Container Network Interface (CNI) - networking for Linux containers](https://github.com/containernetworking/cni)

## Install flannel
> 🚨 DO NOT install if you are going to use **calico**

We are going to install flannel using helm

```shell
kubectl create ns kube-flannel
kubectl label --overwrite ns kube-flannel pod-security.kubernetes.io/enforce=privileged

helm repo add flannel https://flannel-io.github.io/flannel/
helm install flannel --set podCidr="192.168.0.0/16" --namespace kube-flannel flannel/flannel
```

Note that the `podCidr="192.168.0.0/16"` matching to the `kubeadm init --pod-network-cidr 192.168.0.0/16` argument

## Install Calico
> 🚨 DO NOT install, if you are going to use **flannel**

Please review steps in [official documentation](https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart#install-calico)

Execute the following to install:
```shell
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.3/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/alperozisik/k8s-basic-workshop/main/k8s/calico-install/custom-resources.yaml
```

This will going to install some kubernetes compontents. This will take some time. Check the installation as below:
```shell
watch kubectl get pods -n calico-system -o wide
```
You **MUST** see all numbers **full** and **Running** ![](./images/scr-13.png)

To exit *watch* press `CTRL + C`. After that you can continue installation

Note that the `cidr: 192.168.0.0/16` value in [custom-resources.yaml](../../k8s/calico-install/custom-resources.yaml) that we have used while installing is a match to the `kubeadm init --pod-network-cidr 192.168.0.0/16` argument

