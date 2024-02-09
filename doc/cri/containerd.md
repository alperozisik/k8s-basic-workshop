# containerd
containerd is maintained by Docker organization.

You can review [Getting started with containerd](https://github.com/containerd/containerd/blob/main/docs/getting-started.md)

Installation is similar to docker.

You can use the scripted install for a faster installation experience:
```shell
curl https://raw.githubusercontent.com/alperozisik/k8s-basic-workshop/main/scripts/containerd.sh | bash
```

# CRI Socket
> 💡 If there are multiple cri installed, you should specify which one to use. Add, `--cri-socket unix:///var/run/containerd/containerd.sock` whenever if needed. Typically this is not needed with just containerd installation. You can try regular `kubeadm` command. If this is failing due to unspecified cri-socket, add the argument as specified. Be careful while executing kubeadm commands.