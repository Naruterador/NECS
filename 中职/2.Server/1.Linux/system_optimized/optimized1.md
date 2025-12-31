## Rocky linxu 系统做如下优化:
- 系统资源限制设置：设置所有用户的硬件跟软件的最大进程数、最大文件打开数为 65535；
```shell
#您需要编辑/etc/security/limits.conf文件来设置所有用户的硬件和软件的最大进程数以及最大文件打开数。通过添加以下行来实现这一点：
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
#这里，*代表所有用户，nproc是指进程数，nofile是指文件打开数。soft限制是指用户可以增加到的限制，而hard限制是指系统强制的最大值，用户不能超过这个值。
```
  
- 开启 IPV4 恶意 icmp 错误消息保护
```shell
#要开启IPv4恶意icmp错误消息保护，可以通过修改sysctl配置来实现。您需要编辑/etc/sysctl.conf文件，添加或修改以下行：
net.ipv4.icmp_ignore_bogus_error_responses = 1
#这将忽略无效的ICMP错误消息，有助于防止一些DoS攻击。
```





- 开启 SYN 洪水攻击保护
- 开启 IPV4 恶意 icmp 错误消息保护
```shell
#同样在/etc/sysctl.conf文件中，您可以添加或修改以下配置来帮助防护SYN洪水攻击：
net.ipv4.tcp_syncookies = 1
#当系统检测到SYN接收队列快要满时，启用syncookies可以帮助防止SYN洪水攻击，而不需要增加更多的资源。
```


- 允许系统打开的端口范围为 1024-65000
```shell
#修改系统允许打开的端口范围，需要编辑/etc/sysctl.conf文件，添加或修改以下配置：
net.ipv4.ip_local_port_range = 1024 65000
这样设置之后，系统允许打开的本地端口范围就是1024到65000。
```

- 应用配置更改
```shell

对于所有通过修改/etc/sysctl.conf的配置更改，您需要运行以下命令来使配置生效：
sudo sysctl -p

```
