## 多组多从kubernetes配置:

- 基本配置需要和一组多从类似:

- 主节点创建指令:

```shell
kubeadm init --apiserver-advertise-address=192.168.108.51 --kubernetes-version=v1.30.7 --service-cidr=10.96.0.0/12 --pod-network-cidr=10.244.0.0/16 --cri-socket=/run/containerd/containerd.sock --upload-certs --control-plane-endpoint=192.168.108.51:6443



Your Kubernetes control-plane has initialized successfully!
To start using your cluster, you need to run the following as a regular user:
mkdir -p SHOME/. kube
sudo cp -i /etc/kubernetes/admin.conf $H0ME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/. kube/config

Alternatively, if you are the root user, you can run:

export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of the control-plane node running the following command on each as root:

kubeadm join 192.168.186.50:16443 --token abcdef.0123456789abcdef \
--discovery-token-ca-cert-hash sha256:74dc5e7f26f041e65ddc085b8eb9d05233a9394e50a8c19374f9bf5e198a3e5e \
--control-plane --certificate-key fbe0f58aeb0d2e0640f4ddcfcda3afb56ee04ea9a90dab22502511a315843509

Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.186.50:16443 --token abcdef.0123456789abcdef \
--discovery-token-ca-cert-hash sha256:74dc5e7f26f041e65ddc085b8eb9d05233a9394e50a8c19374f9bf5e198a3e5e
```

- `kubeadm join 192.168.186.50:16443 --token abcdef.0123456789abcdef \
--discovery-token-ca-cert-hash sha256:74dc5e7f26f041e65ddc085b8eb9d05233a9394e50a8c19374f9bf5e198a3e5e \
--control-plane --certificate-key fbe0f58aeb0d2e0640f4ddcfcda3afb56ee04ea9a90dab22502511a315843509`

- 上面这段指令用于添加其他的控制节点