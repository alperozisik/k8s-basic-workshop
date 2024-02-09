# Docker installation
In this section we are going to install docker engine community edition and cri-docker.

You can follow the official guide or use the [script](../scripts/docker-install.sh)

## Alternative 1: Official docs
1. Follow the official [Install Docker Engine on Ubuntu guide](https://docs.docker.com/engine/install/ubuntu/)
2. Make sure that [Linux postinstall](https://docs.docker.com/engine/install/linux-postinstall/) are not missed

## Alternative 2: Scripted install
This script performs an installation on a clean system.
```shell
curl https://raw.githubusercontent.com/alperozisik/k8s-basic-workshop/main/scripts/docker-install.sh | bash
newgrp docker
```

# Install cri-dockerd
This enables docker & kubernetes to talk to each other. In earlier versions of Docker this was included in the bundle.

[Official site](https://github.com/Mirantis/cri-dockerd)

Review the [script file](../../scripts/cri-dockerd-install.sh) and execute it. (Release might be updated in future)

```shell
curl https://raw.githubusercontent.com/alperozisik/k8s-basic-workshop/main/scripts/cri-dockerd-install.sh | bash
```

# CRI Socket
> 💡 Docker is always installing 2 cri (both **docker** and **containerd**). `kubeadm` will throw errors for unspecfied cri-scoket. Add argument `--cri-socket unix:///var/run/cri-dockerd.sock`. Be careful while executing kubeadm commands.