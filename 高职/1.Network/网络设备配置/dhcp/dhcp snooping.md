## Dhcp snooping配置

  

```shell

dhcp snooping配置

ip dhcp snooping //全局开启dhcp snooping功能

interface GigabitEthernet 0/23

ip dhcp snooping trust //设置需要转发dhcp报文的上联口作为信任端口

```