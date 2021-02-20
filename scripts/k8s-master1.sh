#!/bin/sh
apt-get update
swapoff -a 
apt-get update && apt-get install -y apt-transport-https curl

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update

apt-get install -y kubelet kubeadm

apt-mark hold kubelet kubeadm 

#Installing docker

sudo apt-get update

sudo apt-get install -y \
	    apt-transport-https \
	        ca-certificates \
		    curl \
		        gnupg-agent \
			    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
	   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	      $(lsb_release -cs) \
	         stable"

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io -y

sudo kubeadm init --control-plane-endpoint "localhost:6443" --upload-certs --pod-network-cidr=192.168.0.0/16 | tee /tmp/masterop.txt

