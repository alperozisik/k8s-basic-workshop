# Container Runtime Interface (CRI)
Kubernetes does not include any container engine. It is compatible with the following 4 engines:
- conainerd
- cri-o
- docker
- mirantis

[Official documentation](https://kubernetes.io/docs/setup/production-environment/container-runtimes/)

Except mirantis all of them are community based. Docker is both commercial and community. That makes mirantis out of scope. containerd and cri-o are free to use commercially.

## Not the best practices
Technically, it is possible to install multiple container engines together on a same system. This is not a practical approach. K8s can only work with a single container engine at the same time.

It is also possile that each node uses a different container engine too. Unless it is a strict requirement, this is not a good practice. Different container engines might possibly lead to different behaviours. For that reason, a pod running on different nodes might behave differently.

## Choosing the correct container engine
OCI uses cri-o as container runtime. In a cluster that you are going to manage, it is possible to use a different one and run it on OCI compute instances. In this workshop, feel free to use any engine that you are picking. For this scope, it does make a difference.

## Container engines & cri installation
Except docker, containerd & cri-o is bundled with cri (the interface that K8s need to talk with container engine). For docker engine, we are going to install that cri plugin additionally. Go to the document, that you pick your engine:

- [cri-o](./cri-o.md)
- [docker](./docker.md)
- [containerd](./containerd.md)