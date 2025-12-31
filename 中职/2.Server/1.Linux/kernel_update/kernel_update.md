#### Rocky Linux内核升级
```shell
#查看当前linux的内核版本
uname -sr


#查看当前系统版本可以支持的kernel版本
yum info kernel -q

#升级当前版本支持的内核版本信息
yum update kernel
#也可以直接使用yum 本地安装


#查看当前已经安装的内核版本情况
yum list kernel

#开机切换版本的内核系统

#再次查看系统内核版本
uname -sr

```
