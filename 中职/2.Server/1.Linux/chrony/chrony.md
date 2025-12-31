## 问题:
- 利用 chrony，配置 linux1 为其他 linux 主机提供 NTP 服务。


## 解:
```shell
# 时间服务器服务端配置
vim /etc/chrony.conf
#pool 2.rocky.pool.ntp.org iburst  #修改本行内容如下
server 10.6.220.101 iburst  

allow 10.10.70.0/24

# Serve time even if not synchronized to a time source. 
local stratum 10     #去掉注释

# 重启服务
systemctl restart chronyd


# 时间服务器客户端配置
vim /etc/chrony.conf
server 10.6.220.101 iburst

# 重启服务
systemctl restart chronyd

#在客户端上查看时间是否同步
chronyc -d sources

```
