# CRI-O
To install follow one of the alternatives:

## Alternative 1: Official documentation
Follow the steps stated in [cri-o install documentation](https://github.com/cri-o/cri-o/blob/main/install.md)

## Alternative 2: Scripted install
For faster installation, you can execute the following:

```shell
curl https://raw.githubusercontent.com/alperozisik/k8s-basic-workshop/main/scripts/cri-o.sh | bash
```

# CRI Socket
> 💡 If there are multiple cri installed, you should specify which one to use. Add, `--cri-socket unix:///var/run/crio/crio.sock` whenever if needed. Typically this is not needed with just containerd installation. You can try regular `kubeadm` command. If this is failing due to unspecifiec cri-socket, add the argument as specified. Be careful while executing kubeadm commands.