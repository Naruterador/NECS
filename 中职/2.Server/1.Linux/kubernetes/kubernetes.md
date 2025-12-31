## kubernetes v1.27.1部署注意点:
- 在倒入kubernetes组件时需要使用--platform arm64参数来指定容器支持的架构,例如:
```
ctr -n k8s.io i import coredns-v1.10.1.tar --platform arm64
```
- 在导入calico的组建时不需添加--platform arm64

- 修改config.toml文件
```shell
sed -i 's#SystemdCgroup = false#SystemdCgroup = true#g' /etc/containerd/config.toml
#这条指令就是将config.toml文件中的SystemdCgroup = false,改为 true,大概在config.toml文件的第125行

#原来部署时需要注视掉/etc/containerd/config.toml中的systemcgroup=false，这里不要注释
```

- 有关从阿里云安装部署kubernetes组件
```shell
vi /etc/containerd/config.toml
#修改pause:3.9的内容如下，因为本身镜像是从阿里云拉取的
sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.9"


#在用kubeadm init 创建集群的时候，我们需要添加如下参数:
--image-repository=registry.aliyuncs.com/google_containers     #指定k8s容器下载路径，默认为google,这里指定为了阿里云的仓库
```

- 修改calico.yaml:

```shell
#将下列内容
image: docker.io/calico/cni:v3.25.0
image: docker.io/calico/cni:v3.25.0
image: docker.io/calico/node:v3.25.0
image: docker.io/calico/node:v3.25.0
image: docker.io/calico/kube-controllers:v3.25.0

#修改为:
image: docker.io/calico/cni:v3.25.0-arm64
image: docker.io/calico/cni:v3.25.0-arm64
image: docker.io/calico/node:v3.25.0-arm64
image: docker.io/calico/node:v3.25.0-arm64
image: docker.io/calico/kube-controllers:v3.25.0-arm64
```

## 题目:
- 在linux5-linux7上安装containerd和kubernetes，linux5作为master node，linux6和linux7作为work node；使用containerd.sock作为容器runtime-endpoint。导入nginx镜像，主页内容为“HelloKubernetes”。
- master节点配置calico，作为网络组件。
- 创建一个deployment，名称为web，副本数为2；创建一个服务，类型为nodeport，名称为web，映射本机80端口和443端口分别到容器的80端口和443端口。

## 解:
```shell    
openssl genpkey -algorithm RSA -out server.key
openssl req -new -key server.key -out server.csr
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt

kubectl create secret tls my-secret --cert=server.crt --key=server.key
```


```yaml
# https configmap https.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
data:
  http.conf: |
    server {
        listen       80;
        server_name  localhost;
        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
            add_header Content-Type text/plain;
            return 200 'HelloKubernetes\n';
        }
    }
  https.conf: |
    server {
        listen       443 ssl;
        server_name  localhost;
        ssl_certificate /etc/nginx/ssl/tls.crt;
        ssl_certificate_key /etc/nginx/ssl/tls.key;
        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
            add_header Content-Type text/plain;
            return 200 'HelloKubernetes\n';
        }
    }
```

```yaml
# deployment deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: docker.io/library/nginx:9.9
        ports:
        - containerPort: 80
        - containerPort: 443
        volumeMounts:
        - name: config-volume
          mountPath: /etc/nginx/conf.d
        - name: config-ssl
          mountPath: /etc/nginx/ssl
      volumes:
      - name: config-volume
        configMap:
          name: nginx-config
          items:
          - key: http.conf
            path: http.conf
          - key: https.conf
            path: https.conf
      - name: config-ssl
        secret:
          secretName: my-secret
```


```yaml
# service service.yaml

apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  type: NodePort
  ports:
  - name: http
    port: 80
    targetPort: 80
    nodePort: 30080
  - name: https
    port: 443
    targetPort: 443
    nodePort: 30443
  selector:
    app: web

# port 表示 Service 对外暴露的端口号，targetPort 表示服务后端 Pod 中容器实际监听的端口号。
```
