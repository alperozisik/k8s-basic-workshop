# OCI Unbuntu Image
OCI platform images are shipped with firewall enabled by default. Also blocking some requeststs. OCI Ubuntu image uses **iptables**. We are going to flush the entries from iptables and allowing all. We are not going to totally disable iptables, k8s uses iptables for networking.

# iptables
iptables is not essential for Kubernetes networking, but it's often used in conjunction with Kubernetes to manage network traffic. In Kubernetes, iptables is used to enforce network policies, handle port forwarding, and perform Network Address Translation (NAT) for container traffic.

While Kubernetes can function without iptables, many network plugins and features rely on iptables for network isolation, routing, and security. Therefore, iptables is commonly installed and configured on Kubernetes nodes to ensure proper networking functionality.

However, it's worth noting that some container runtimes, such as containerd or CRI-O, may have their own network management mechanisms and may not rely heavily on iptables. Ultimately, the need for iptables in a Kubernetes environment depends on the specific networking requirements and the chosen networking solution


# More information
- [k8s ports](https://kubernetes.io/docs/reference/networking/ports-and-protocols/)
- OCI Platform Images, [Essential Firewall Rules](https://docs.oracle.com/en-us/iaas/Content/Compute/References/images.htm#image-firewall-rules)