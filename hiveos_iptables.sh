#!/bin/bash


sudo systemctl stop nftables
sudo systemctl disable nftables
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy



# Allow Kubernetes API server traffic (default port 6443)
sudo iptables -A INPUT -p tcp --dport 6443 -j ACCEPT

# Allow traffic for etcd (default ports 2379-2380)
sudo iptables -A INPUT -p tcp --dport 2379:2380 -j ACCEPT

# Allow traffic for kubelet (default port 10250)
sudo iptables -A INPUT -p tcp --dport 10250 -j ACCEPT

# Allow traffic for kube-scheduler (default port 10251)
sudo iptables -A INPUT -p tcp --dport 10251 -j ACCEPT

# Allow traffic for kube-controller-manager (default port 10252)
sudo iptables -A INPUT -p tcp --dport 10252 -j ACCEPT

# Allow NodePort range (default range 30000-32767)
sudo iptables -A INPUT -p tcp --dport 30000:32767 -j ACCEPT

CONFIG_FILE="/etc/rc.local"
sudo iptables -L -n
sudo iptables-save | sudo tee /etc/iptables/rules.v4
cat <<EOL >> "$CONFIG_FILE"
#!/bin/bash
iptables-restore < /etc/iptables/rules.v4
exit 0
EOL



sudo chmod +x /etc/rc.local
sudo systemctl restart kubelet
kubectl get nodes
