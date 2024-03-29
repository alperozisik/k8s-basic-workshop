# Kubernetes Installation
This will install the required packages, just before initializing the cluster.

## Basics
1. OS Configurations
2. Install the Container Runtime - Docker
3. K8s installation
4. Install helm
5. Create image

You are given script files to automate the installation. This will greately speed up the process. They are kept up-to-date as needed. Make sure that they are not outdated.

> Make sure all steps are completed in order

## 1. OS Configurations
We have selected Ubuntu 22.04 as the OS. Through rest of the workshop, commands are tailored for the specific OS.
1. **Update system**  
    Even we are using the most recent versions of the OS, the bundled packages could be outdated. Best to start with most up-to-date system
    ```shell
    sudo apt update
    sudo apt upgrade -y
    ```
    This update process might be showing some interactive terminal inputs. Like asking which services to restart. Use default selections. If needed, use `tab` key to navigate, `enter` key to accept.  
    This first upgrade usually is a big update. In most of the cases system looses stability. To fix this rebooting helps.
    ```shell
    sudo reboot
    ```
    Rebooting causes VScode to disconnect. Wait a while (typically 30 seconds). And have the VSccode to reload ![](./images/scr-12.png)

2. **Disable swap**
    ```shell
    sudo apt install cron -y
    sudo swapoff -a
    (sudo crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | sudo crontab - || true
    ```
3. **Open ports on firewall**  
    ```shell
    curl https://raw.githubusercontent.com/alperozisik/k8s-basic-workshop/main/scripts/iptables.sh | bash
    ```
    Details explained under [firewall documentation](./firewall.md)
## 2. Container Runtime

It is possible to work with a selection container engine. Please follow [cri document](./cri)


## 3. K8s installation
We are going to install necessary tools to initialize a k8s cluster.

You will install these packages on all of your machine:
- **kubeadm:** the command to bootstrap the cluster.
- **kubelet:** the component that runs on all of the machines in your cluster and does things like starting pods and containers.
- **kubectl:** the command line util to talk to your cluster

You can check the official documentation: [Installing kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-runtime), which will install all of them.

> This environment that is provided by OCI & Ubuntu. It is quite up-to-date. Most of the prerequisites in the documentation is already met.

Please review the [install script](../scripts/kubeadm-install.sh) and perform installation as following:
```shell
curl https://raw.githubusercontent.com/alperozisik/k8s-basic-workshop/main/scripts/kubeadm-install.sh | bash
```

### Apply quick reference tips
Open `~/.bashrc` for edit:
```shell
code ~/.bashrc
```
Add the following lines to the end and save
```shell
source <(kubectl completion bash)
alias k=kubectl
complete -o default -F __start_kubectl k
```

## 4. Install helm
Helm is a package manager for k8s. In the next step, we will be creating an image. It is good to include it in the image.
It can be installed easly as stated in [the official documentation](https://helm.sh/docs/intro/install/#from-apt-debianubuntu)
```shell
curl https://raw.githubusercontent.com/alperozisik/k8s-basic-workshop/main/scripts/helm-install.sh | bash
```

## 7. Fetch K8s images
It would be good practice to pre-download the K8s images. Use the following command to download k8s images:
```shell
sudo kubeadm config images pull
```
> 💡 This `kubeadm` command might require you to specify `--cri-socket` argument. Please refer to your installed container engine installation document, which you have completed earler.


## 6. Create Image
> YES! You need to perform the step now!

1. If you are not familiar with creating images, review the [Creating a Custom Image document](https://docs.oracle.com/en-us/iaas/secure-desktops/create-custom-image.htm)
2. Create image in same compartment, name it as `k8s-base`. While creating the image, machine will be offline, automatically restart afterwards. Do not refresh VScode window, until instance status becomes ready. ![](./images/scr-12.png)

> It is expected to reboot the system at once. The firewall settings that we enabled earlier, does not kick-in without reboot. This is essential while we are adding workers to cluster. Creating image handles that reboot for us. If you are not going through this step, you can preform reboot now