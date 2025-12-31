1️⃣ Nginx 核心参数（/etc/nginx/nginx.conf）
```c
worker_processes auto;
worker_rlimit_nofile 100000;

events {
    use epoll;
    worker_connections 65535;
    multi_accept on;
}
```

- 改完记得：`nginx -t && systemctl reload nginx`


### 2️⃣ 系统参数（/etc/sysctl.conf）

追加：
```shell
vim /etc/sysctl.conf
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_max_syn_backlog = 8192
fs.file-max = 1000000




```

执行：
```shell
sysctl -p
```

再设置当前会话文件句柄：
```shell
ulimit -n 100000
```

配置LimitNOFILE
- 创建override目录（如果没有就创建，一般直接就有）
```
mkdir -p /etc/systemd/system/nginx.service.d
```
- 创建 override 配置文件 limit.conf
 ```shell
vim /etc/systemd/system/nginx.service.d/limit.conf
 ```
- 加入以下内容
```shell
[Service]
LimitNOFILE=100000
```

- 重新加载 systemd 服务配置,并重启nginx
```shell
systemctl daemon-reload
systemctl restart nginx
```