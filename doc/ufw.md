Using **iptables** is advised, instead of **ufw**.

If you want to use ufw, here are the commands that opens the ports.

> ⚠️ Those changes are sufficient for the workshop. Not guarantieed to work on production.

```shell
sudo ufw enable
sudo ufw allow 6443
sudo ufw allow 2379:2380/tcp
sudo ufw allow 10250/tcp
sudo ufw allow 10255/tcp
sudo ufw allow 179/tcp
sudo ufw allow 10259/tcp
sudo ufw allow 10257/tcp
sudo ufw allow 30000:32767/tcp
sudo ufw allow 8285/udp
sudo ufw allow 8472/udp
```
