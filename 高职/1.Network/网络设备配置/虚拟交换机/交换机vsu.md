## 配置交换机vsu（双设备聚合）

- Switch-1 及 Switch-2 组成 VSU，domain 域为 100，左边机箱配置成机箱号 1，优先级 200，别名 switch-1，上面有端口 1/1、1/2 为 VSL 口。右边机箱配置成机箱号 2，别名 switch-2，优先级 100，上面有端口 1/1、1/2 为 VSL 口。

- 配置方法

- Switch-1 机箱上配置：

- 配置 VSU 属性、VSL 口。

- 将单机模式转换成 VSU 模式。

- Switch-2 机箱上配置：

- 配置 VSU 属性、VSL 口。

- 将单机模式转换成 VSU 模式。

  

```shell

Switch-1 Ruijie# configure terminal

Ruijie(config)# switch virtual domain 100 //配置域id

Ruijie(config-vs-domain)#switch 1 //配置设备在虚拟设备中的编号

Ruijie(config-vs-domain)#switch 1 priority 150 //配置设备优先级

Ruijie(config)#vsl-port //进入vsl端口配置模式

Ruijie(config-vsl-port)#port-member interface gi0/49,50 //将49,50口配置为vsl接口

Ruijie#switch convert mode virtual //单机模式切换到 VSU 模式

Switch-2 Ruijie# configure terminal

Ruijie(config)# switch virtual domain 100

Ruijie(config-vs-domain)# switch 2

Ruijie(config-vs-domain)# switch 2 priority 120

Ruijie(config)#vsl-port

Ruijie(config-vsl-port)#port-member interface gi0/48

Ruijie#switch convert mode virtual

  

#配置BFD双主机检测端口

Ruijie(config)# interface GigabitEthernet 1/1/1

Ruijie(config-if- GigabitEthernet 1/1/1)# no switchport //将检测接口设置为路由口

Ruijie(config)# interface GigabitEthernet 2/1/1

Ruijie(config-if- GigabitEthernet 2/1/1)# no switchport //二口必须位于不同设备

Ruijie(config)# switch virtual domain 1 //进入config-vs-domain配置模式

Ruijie(config)# dual-active detection bfd //打开bfd开关

Ruijie(config-vs-domain)# dual-active bfd interface GigabitEthernet 1/1/1 //配置接口

Ruijie(config-vs-domain)# dual-active bfd interface GigabitEthernet 2/1/1

  

#使用 show switch virtual config 命令查看 Switch-1、Switch-2 的 VSU 属性

```