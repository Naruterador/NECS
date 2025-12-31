  

#IP/MAC 欺骗攻击防范

- 防止用户私设 IP 地址或防止用户伪造 IP 报文进行攻击

- 打开 DHCP Snooping 功能。略

- 开启 IP Source Guard。

  

```shell

Ruijie(config)# interface GigabitEthernet 0/2

Ruijie(config-if-GigabitEthernet 0/2)# ip verify source //仅监听ip部分，禁止用户私设ip地址

Ruijie(config-if-GigabitEthernet 0/2)# ip verify source port-security //设置IP/MAC的欺骗攻击防范

```