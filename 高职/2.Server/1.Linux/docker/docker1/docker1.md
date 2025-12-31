## 问题：
- 编写 Dockerfile 文件构建 mysql 镜像，要求基于 centos 完成 MariaDB 数据库的安装和配置，并设置服务开机自后。
- 编写 Dockerfile 构建镜像 erp-mysql:vl.0，要求使用 centos7.9.2009镜像作为基础镜像，完成 MariaDB 数据库的安装，设置 root 用户的密码为 tshoperp，新建数据库jsh_erp 并导入数据库文件 jsh_erp.sql，并设置 MariaDB 数据库开机自启.
- 所用镜像是 rockylinux:9.3.20231119

```shell
#倒出数据库jsh_erp成jsh_erp.sql
mysqldump -uroot -ptshoperp jsh_erp > jsh_erp.sql
```

## 解:
```shell
#编写dockerfile
vim /root/Dockerfile

FROM rockylinux:9.3.20231119
# 安装 MariaDB 数据库服务器
RUN yum -y install mariadb*

COPY init-db.sh /root/init-db.sh
COPY jsh_erp.sql /root/jsh_erp.sql
RUN chmod +x /root/init-db.sh

# 设置 MariaDB 数据库开机自启
RUN systemctl enable mariadb

# 暴露 3306 端口
EXPOSE 3306

# 设置启动命令
CMD ["sh","/root/init-db.sh"]

##############################################################################################################

#编辑init-db.sh
vim /root/init-db.sh

#!/bin/bash

mysql_install_db --user=mysql
sleep 10

mysqld_safe &

sleep 10

# 设置 root 用户密码
mysqladmin -u root password 'tshoperp'

# 创建数据库 jsh_erp
mysql -uroot -ptshoperp -e "CREATE DATABASE jsh_erp;"

#导入数据库jsh_erp
mysql -uroot -ptshoperp "jsh_erp" < "/root/jsh_erp.sql"

sh -c "while true; do echo hello world; sleep 1; done"

##############################################################################################################

#构建docker
docker build -t erp-mysql:v1.0 .

#运行docker
docker run -d -p 3306:3306 --privileged erp-mysql:v1.0

# --privileged：这个参数会赋予容器访问主机上所有设备的权限，这样容器内的进程就可以执行一些特权操作，比如修改网络设置和访问主机设备。这个选项潜在地增加了容器逃逸的风险，因为容器内的进程可以影响主机的行为。因此，在使用时应当谨慎，并避免在生产环境中使用。

# --cap-add=ALL：这个参数用于向容器添加特定的 Linux capabilities（能力）。Linux capabilities 是一种机制，允许对于普通用户进程开启部分特权，而不是让它们完全拥有超级用户权限。ALL 表示添加所有 capabilities，这可能会增加容器的特权级别，需要慎重考虑潜在的安全风险。
```