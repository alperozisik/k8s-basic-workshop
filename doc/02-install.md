# Kubernetes Installation
This will install the required packages, just before initializing the cluster.

## Basics
1. OS Configurations
2. Install the Container Runtime - Docker
3. K8s components installation
4. Create image

> Make sure all steps are completed in order

## 1. OS COnfigurations
We have selected Ubuntu 22.04 as the OS. Through rest of the workshop, commands are tailored for the specific OS.

1. Disable swap
    ```shell
    sudo swapoff -a
    ```
2. Disable firewall  
    ```shell
    sudo systemctl stop ufw
    sudo systemctl disable ufw
    ```
    > Normally you do not disable the firewall, instead configure it for [the ports](https://kubernetes.io/docs/reference/networking/ports-and-protocols/). We are skipping this, just disabling for the workshop. There is nothing much sensitive running here.

## 2. Container Runtime
There are multiple container runtimes are supported by Kubernetes. For this workshop we will be using docker.

### 2.1 Docker installation

You can follow the official guide or use the [script](../scripts/docker-install.sh) (it could be outdated) to automate it all

#### Official docs
1. Follow the official [Install Docker Engine on Ubuntu guide](https://docs.docker.com/engine/install/ubuntu/)
2. Make sure that [Linux postinstall](https://docs.docker.com/engine/install/linux-postinstall/) are not missed

#### Scripted install
```shell
curl <github url> | bash
```