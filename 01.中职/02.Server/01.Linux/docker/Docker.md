## 问题：
- 利用/root/root/Dockerfile文件，构建镜像名称为rocky-mariadb，部署mariadb服务，实现mariadb开机自启，并且暴露端口为3306；构建完成后启动容器，容器名称为mariadb。
## 解：
- 在linux3中安装Docker服务

```
yum install docker* -y
```

- 导入rockylinux-9.tar镜像

```
docker load < rockylinux-9.tar
```

- 查看镜像是否导入成功

```
docker images
```

- 在/root底下创建一个Dockerfile文件

```
vi /root/Dockerfile

FROM docker.io/library/rockylinux:9
RUN rm -rf /etc/yum.repos.s/*
COPY a.repo /etc/yum.repos.d/a.repo
RUN yum install mariadb* -y
RUN mariadb-install-db --user=mysql --datadir=/var/lib/mysql/
CMD ["mysqld_safe"]
EXPOSE 3306
```

- 构建Dockerfile文件

```
docker build -t erp-mysql:v1.0 .
```

- 再次查看镜像

```
docker images
```

- 运行mariadb容器

```
docker run -d -p 3306:3306 --privileged 903d47e5f61b
```

- 查看容器是否启动成功

```
docker ps
```
