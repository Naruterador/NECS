## 需求分析
- 环境:
  - Linux 9.2 Arm64
- 具体要求:
  - 在linux1使用 cgroup2 限制 Apache HTTPD 对系统资源的使用
  - 只允许相关进程使用第 2个 CPU 核心
  - CPU 负载不能超过80%
  - 占用内存容量不能超过512MB

## 完成思路
- cgroup2和systemd在现代Linux系统中已经深度绑定。从systemd的版本219开始，systemd就已经开始使用cgroup2（也称为统一的控制组层次结构）作为其资源管理的基础.

```shell
## systemd配置:

创建自定义文件:
vim /etc/systemd/system/httpd_custom.service

[Unit]
Description=Apache with custom cgroup settings
After=network.target

[Service]
ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
Restart=always

# CGroup settings
MemoryMax=512M
CPUQuota=80%
# 适用于systemd 244及以上版本
#AllowedCPUs=1
# 或者对于较旧的版本
CPUAffinity=1

[Install]
WantedBy=multi-user.target

## 生效服务
systemctl daemon-reload
systemctl stop httpd # 如果httpd服务正在运行的话
systemctl start httpd_custom
systemctl enable httpd_custom

## 测试:
#在其他linux上使用siege做压力测试:
siege -c 100 -t 30S http://172.16.81.205

#查看CPU和新使用情况
ps -o pid,psr,comm -C httpd
#pid：表示进程ID，是系统唯一分配给每个进程的标识符。
#psr：表示处理器编号，即该进程正在使用的CPU核心的编号。在多核心系统中，这可以帮助你了解进程的亲和性，即它主要在哪个核心上执行。
#comm：表示命令名，即启动该进程的命令的名称。

top

##其他
#查看systemd版本
/usr/lib/systemd/systemd --version
```