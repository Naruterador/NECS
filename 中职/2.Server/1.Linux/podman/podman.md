## 问题:
  - 在 linux3 上安装 podman，导入 rockylinux-9.tar 镜像。
  - 创建名称为 skills 的容器，映射本机的 8000 端口到容器的 80 端口，在容器内安装 httpd，默认网页内容为“HelloDocker”。
  - 导入 registry.tar 镜像，创建名称为 registry 的容器。修 rockylinux 镜像的 tag为 linux3.skills.com:5000/rockylinux:9，上传该镜像到私有仓库。

# 解1:
```shell
    podman load < registry.tar 
    podman load < rockylinux-9.tar 
    podman run -d -p 8000:80 --name=skills docker.io/library/rockylinux:9 sh -c "while true;do sleep 10;done"
    

    #配置容器安装apache:
    podman exec -it 9c8acc3a1dea /bin/bash
    ...配置yum源，安装httpd等
    httpd -k start   #启动apache
```



## 问题:
- 配置podman私有仓库

## 解:
```shell
##创建私有仓库
#使用localhost:5000端口创建私有仓库
podman run -d -p 5000:5000 --restart=always --name registry registry:2

## 测试私有仓库
#先将本地仓库中docker.io/library/nginx:latest容器的名称改为localhost:5000/my-nginx:slim
podman tag docker.io/library/nginx localhost:5000/my-nginx

#将远程仓库中的镜像上传到私有仓库
podman push --tls-verify=false localhost:5000/my-nginx

#删除本地仓库的中的镜像
podman rmi localhost:5000/my-nginx

#从私有仓库中拉取镜像到本地
podman pull --tls-verify=false localhost:5000/my-nginx

#查看本地仓库
podman images

#停止私有仓库
podman container stop registry

#移除私有仓库
podman container rm -v registry

#删除私有仓库镜像
podman rmi registry:2
podman rmi localhost:5000/my-nginx:latest 

#查看删除情况
podman images
podman ps
```

## 问题:
- 配置https podman私有仓库
- 有关配置参数说明:

```shell
#下面是一个启动仓库的样例
docker run -d \
  --restart=always \
  --name registry \
  -v "$(pwd)"/certs:/certs \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
  -p 443:443 \
  registry:2

# -v "$(pwd)"/certs:/certs 
#该部分指定了数据卷挂载。它由冒号（:）分隔为两部分。左侧是主机上的路径，右侧是容器内部的路径

# -e REGISTRY_HTTP_ADDR=0.0.0.0:443 
#用于修改容器内仓库镜像的端口，默认为5000

# -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt
# -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key 
# 上面指令用于指定证书和私钥

#在给定的Docker命令中，-p 5000:5000表示进行端口映射。具体解释如下：
#前端口（主机端口）：5000
#后端口（容器端口）：5000

#对于证书，由于仓库支持TLS 1.3所以，证书必须包含IP SANs和DNS信息，否则将无法将远程镜像导入本地仓库
```
- 登录私有仓库时使用账号密码
- 使用htpasswd工具生成登录私有仓库的账号密码并放到auth文件中

```shell
#代码格式
htpasswd -nb username password

#创建用户为test 密码为123456
htpasswd -Bbn test 123456 > /opt/auth/authfile
```
- 利用创建好的账号的密码创建私有仓库
```shell
docker run -d \
  -p 5000:5000 \
  --restart=always \
  --name registry \
  
  -v /opt/auth:/opt/auth \
  -e REGISTRY_AUTH=htpasswd \
  -e REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/opt/auth/authfile \
  
  -v /certs:/certs \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
  registry:2
```

- 测试
```shell
#使用docker login指令登录容器测试
docker login myregistrydomain.com:5000
``````


## 解:
```shell
docker run -d \
  --restart=always \
  --name registry \
  -v /etc/ssl:/etc/ssl \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/etc/ssl/server.crt \
  -e REGISTRY_HTTP_TLS_KEY=/etc/ssl/server.key \
  -p 5000:5000 \
  registry:2


#测试是否导入
curl https://192.168.107.150:5000/v2/_catalog -k
```
