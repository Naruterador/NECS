## 题目
  - 1.在linux5 上安装kubernetes，linux6-linux7 作为kubernetes 的节点，搭建一主二从的单集群，初始化配置文件存放路径为/root/k8s-init/k8s.yaml。
  - 2.使用 containerd 管理容器。

## 答案
```shell
#创建k8s初始化文件到/root/k8s-init/k8s.yaml
kubeadm config print init-defaults > /root/k8s-init/k8s.yaml
```

- 修改/root/k8s-init/k8s.yaml
```yaml
apiVersion: kubeadm.k8s.io/v1beta3
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: abcdef.0123456789abcdef
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 10.60.40.105    #修改集群地址
  bindPort: 6443
nodeRegistration:
  criSocket: unix:///run/containerd/containerd.sock    #修改支持containerd
  imagePullPolicy: IfNotPresent
  name: linux5.skills.com                             #修改当前主机名
  taints: null
---
apiServer:
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta3
clusterName: kubernetes
controllerManager: {}
dns: {}
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: registry.k8s.io
kind: ClusterConfiguration
kubernetesVersion: 1.30.0
networking:
  dnsDomain: cluster.local
  serviceSubnet: 10.96.0.0/12
scheduler: {}
```
