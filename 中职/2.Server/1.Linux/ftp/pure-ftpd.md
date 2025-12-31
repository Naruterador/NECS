### 安装pure-ftpd
```
#安装gcc环境
yum install gcc*

#解压缩pure-ftpd源码包
tar -zxvf /opt/pure-ßftpd-1.0.52.tar.gz
cd /opt/pure-ftpd-1.0.52

#编译源码包
./configure --with-puredb --with-uploadscript
make
make install
```

### 配置虚拟用户
```
#ftp1、ftp2，虚拟用户根目录
mkdir -p /data/ftp/ftp1
mkdir -p /data/ftp/ftp2

#创建虚拟用户映射的本地用户ftpvirtual
useradd -d /data/ftp -s /sbin/nologin ftpvirtual
chown -R ftpvirtual:ftpvirtual /data/ftp

#创建虚拟用户ftp1、ftp2
pure-pw useradd ftp1 -u ftpvirtual -g ftpvirtual -d /data/ftp/ftp1
pure-pw useradd ftp2 -u ftpvirtual -g ftpvirtual -d /data/ftp/ftp2

#将虚拟用户写入数据库
pure-pw mkdb /opt/pureftpd.pdb

#编辑pure-ftpd配置文件
vim /opt/pure-ftpd-1.0.52/pure-ftpd.conf

#关闭匿名用户访问
AnonymousOnly                no
NoAnonymous                  yes
#开启虚拟用户数据库功能
PureDB                       /opt/pureftpd.pdb

#启动服务
pure-ftpd /opt/pure-ftpd.conf
```
