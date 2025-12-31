## mpls配置

```shell

Ruijie(config)# mpls ip //全局使能

Ruijie(config)# interface gigabitEthernet 2/2

Ruijie(config-if-GigabitEthernet 2/2)# label-switching //接口中使能mpls转发

Ruijie(config)# mpls router ldp //开启ldp协议，进入ldp配置界面

Ruijie(config-mpls-router)# ldp router-id {ip-address} //设置ldp的静态route id

Ruijie(config)# interface gigabitEthernet 2/2

Ruijie(config-if-GigabitEthernet 2/2)# mpls ip //接口中开启ldp交换

#使用show mpls ldp neighbor命令查看ldp会话的建立情况

```