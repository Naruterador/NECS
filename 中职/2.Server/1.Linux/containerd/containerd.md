## 问题:

- 任务描述：请采用containerd，实现无守护程序的容器应用。
  - 在linux3上安装containerd，导入rocky镜像。
  - 创建名称为skills的容器，映射本机的8000端口到容器的80端口，在容器内安装apache2，默认网页内容为“HelloPodman”。

## 解:
- 由于containerd自带的指令ctr和ctrcli指令功能不全，无法完成配置，所以要完成本题，需要安装nerdcli工具

```shell
#安装containerd

#安装nerdcli指令
mkdir -p /usr/local/containerd/bin/ && tar -zxvf nerdctl-0.11.0-linux-amd64.tar.gz nerdctl && mv nerdctl /usr/local/containerd/bin/ 
ln -s /usr/local/containerd/bin/nerdctl /usr/local/bin/nerdctl 

#启动容器
nerdctl run -d -p 8000:80 --name=skills docker.io/library/rockylinux@sha256:af5f715cc39624dd78305adcda164e8327a17444e785220c3cf0e8d2b8c2dd6b sh -c "while true; do sleep 10; done"
#sh -c "while true; do sleep 10; done"  用于让容器一直处于开启状态

#进入容器执行指令
nerdctl exec -it skills bash

#安装Apache服务
使用网络yum源安装,http://x.x.x.x:9090/cdrom/AppStream


#将主机文件复制到容器
nerdctl cp /a skills:/opt/a
```

### 利用httpd操作apache服务
```shell
#因为rocky9的容器中没有预装systemctl，所以我们用httpd来操作服务

#启动
httpd –k start

#重启
httpd –k restart

#停止
httpd –k stop
```

## 其他ctr指令介绍

```shell
ctr run \
  --net-host \
  --rm \
  --env PORT=8080 \
  docker.io/khaosdoctor/simple-node-api:latest \
  skills

#ctr run:创建容器的命令

#--net-host:允许通过主机访问容器网络(这样我们就可以访问我们的API)

#--rm:运行后移除容器

#--env PORT=8080:在容器内创建了一个名为PORT的环境变量,其值为8080,如图像文档所述

#docker.io/khaosdoctor/...:需要运行的容器镜像

#skills:给容器命名

ctr task ls
#列出系统中所有当前正在运行的任务（容器）

ctr container ls
#列出系统中所有可用的容器，包括已停止的容器。

ctr task kill 
#终止正在运行的容器任务
ctr task kill skills --signal SIGKILL
#如果无法终止容器，可以使用以上指令


```


## 为contianerd安装cni网络插件（不安装将无法启动containerd容器）
- 将cni-plugins-linux-arm64-v1.3.0.tgz解压缩，并将解压缩后的所有文件复制到/opt/cni/bin目录下覆盖掉原文件

- 使用如下命令新建网络
```shell
#新建网络名称为skillsnet01,网络模式为桥接，网段为172.16.77.0/24,网关地址为172.16.77.254
nerdctl network create --driver=bridge --subnet=172.16.77.0/24 --gateway=172.16.77.254 skillsnet01

#查看创建好的网络
nerdctl network inspect skillsnet01
```


## 使用nerdctl network create创建的网络来启动容器
- 方法1:直接启动


```shell
#使用创建的skillsnet01网络创建运行容器rockylinux
nerdctl run -d -p 8000:80  --network=skills af5f715cc396 sh -c "while true; do sleep 10; done"

#查看容器进程编号
nerdctl ps

#进入容器进行操作
nerdctl exec -it 4afbef1fe2c5 /bin/bash

#查看当前运行容器的网络
nerdctl inspect 4afbef1fe2c5
```
  
-方法2:假设把containerd的容器导入k8s.io的命名空间中启动容器
```shell  
#使用创建的skillsnet01网络创建运行容器rockylinux
nerdctl run --namespace k8s.io -d -p 8000:80  --network=skills af5f715cc396 sh -c "while true; do sleep 10; done"
  
#查看容器进程编号
nerdctl --namespace k8s.io ps
  
#进入容器进行操作
nerdctl exec --namespace k8s.io -it 4afbef1fe2c5 /bin/bash
 
#查看当前运行容器的网络
nerdctl inspect --namespace k8s.io 4afbef1fe2c5
```

## 配置containerd指向私有仓库
```shell
#导出配置文件
containerd config default> /etc/containerd/config.toml

#修改config.toml文件
vim /etc/containerd/config.toml

#找到 [plugins."io.containerd.grpc.v1.cri".registry]
#修改相应配置，具体配置如下:
 [plugins."io.containerd.grpc.v1.cri".registry]
[plugins."io.containerd.grpc.v1.cri".registry.mirrors]
[plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.xx.vip"]
endpoint = ["https://docker.xx.vip"]
[plugins."io.containerd.grpc.v1.cri".registry.auths]
[plugins."io.containerd.grpc.v1.cri".registry.configs]
[plugins."io.containerd.grpc.v1.cri".registry.configs."docker.xx.vip".auth]
username = "xx"
password = "xx"
[plugins."io.containerd.grpc.v1.cri".registry.headers]

```
