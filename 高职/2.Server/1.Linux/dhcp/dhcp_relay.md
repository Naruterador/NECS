#### 配置 DHCP 转发代理
- 配置系统为Rocky Linux 9
- 配置过程:
```shell
#安装 dhcp-relay 软件包
dnf install dhcp-relay

#将 /lib/systemd/system/dhcrelay.service 文件复制到 /etc/systemd/system/ 目录中
cp /lib/systemd/system/dhcrelay.service /etc/systemd/system/

# 编辑 /etc/systemd/system/dhcrelay.service 文件，并追加 -i interface 参数以及负责该子网的 DHCPv4 服务器的 IP 地址列表
ExecStart=/usr/sbin/dhcrelay -d --no-pid -i ens160 -i ens224 192.168.100.100
#dhcrelay 会侦听 ens160和ens224 接口上的 DHCPv4 请求，并将它们转发到 IP 为 192.168.100.100 的 DHCP 服务器。

#重新加载 systemd 管理器配置
systemctl daemon-reload

#启动 dhcrelay 服务
systemctl start dhcrelay.service

#查看 dhcp 服务器记录的信息
cat /var/lib/dhcpd/dhcpd.leases
```