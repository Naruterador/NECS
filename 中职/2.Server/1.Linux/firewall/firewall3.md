## 省赛题解析
### 问题：
- 使用 firewall-cmd 将 10.12.97.0/20 网段对 Linux-6、Linux-7 主机的访问 流量导入 work 区域
### 解:
```shell
firewall-cmd --permanent --zone=work --add-source=10.12.97.0/20
```

- 在 Linux-6 、Linux-7 主机上的 work 区域增加拒绝来自 10.2.97.0/24 对 DNS 服务的访问的相关 rich rules 条目
### 解:
```shell
#分别在linux6和7上执行
firewall-cmd --permanent --zone=work --add-rich-rule='rule family="ipv4" source address="10.2.97.0/24" service name="dns" reject'
firewall-cmd --permanent --zone=work --add-rich-rule='rule family="ipv4" source address="10.2.97.0/24" service name="dns" reject'
```
- 在 Linux-6主机上的 work 区域增加拒绝来自10.2.96.0/24 对 NTP 服务的访问的相关 rich rules 条目
### 解:
```shell
firewall-cmd --permanent --zone=work --add-rich-rule='rule family="ipv4" source address="10.2.96.0/24" service name="ntp" reject'
```

- 在 Linux-7主机上的 work 区域增加拒绝来自 210.29.98.0/24 对 http、https、samba 服务的访问的相关 rich rules 条目，其他 IP 地址正常访问相关主机服务。
### 解:
```shell
# 添加允许其他 IP 地址访问 http、https、samba 服务的 rich rule 
firewall-cmd --permanent --zone=work --add-rich-rule='rule family="ipv4" source address="!" service name="http" accept'
firewall-cmd --permanent --zone=work --add-rich-rule='rule family="ipv4" source address="!" service name="https" accept'
firewall-cmd --permanent --zone=work --add-rich-rule='rule family="ipv4" source address="!" service name="samba" accept'
#通过在 source address 中使用 !，你在规则中排除了指定的源地址，使规则适用于其他所有地址。
#请注意，source address="!" 的使用可能需要谨慎，因为它将匹配所有不在指定范围内的源地址。


# 添加拒绝来自 210.29.98.0/24 网段对 http、https、samba 服务的访问的 rich rule
firewall-cmd --permanent --zone=work --add-rich-rule='rule family="ipv4" source address="210.29.98.0/24" service name="http" reject'
firewall-cmd --permanent --zone=work --add-rich-rule='rule family="ipv4" source address="210.29.98.0/24" service name="https" reject'
firewall-cmd --permanent --zone=work --add-rich-rule='rule family="ipv4" source address="210.29.98.0/24" service name="samba" reject'
```