## 配置vrrp聚合

  

```shell

#VRRP

SwitchA(config)# interface vlan 20

SwitchA(config-if-VLAN 20)# ip address 192.168.20.2 255.255.255.0

SwitchA(config-if-VLAN 20)# vrrp 20 ip 192.168.20.1

SwitchA(config-if-VLAN 20)# exit

SwitchA(config)# interface vlan 30

SwitchA(config-if-VLAN 30)# ip address 192.168.30.2 255.255.255.0

SwitchA(config-if-VLAN 30)# vrrp 30 ip 192.168.30.1

SwitchA(config-if-VLAN 30)# exit

SwitchA(config)# interface vlan 40

SwitchA(config-if-VLAN 40)# ip address 192.168.40.2 255.255.255.0

SwitchA(config-if-VLAN 40)# vrrp 40 ip 192.168.40.1

SwitchA(config-if-VLAN 40)# exit

  
  

# 将Switch A的备份组10、20的优先级调高为120。

SwitchA(config)# interface vlan 10

SwitchA(config-if-VLAN 10)# vrrp 10 priority 120

SwitchA(config-if-VLAN 10)# exit

SwitchA(config)# interface vlan 20

SwitchA(config-if-VLAN 20)# vrrp 20 priority 120

SwitchA(config-if-VLAN 20)# exit

  
  

# 配置Switch A的端口GigabitEthernet 0/1为Route Port，并配置IP地址为10.10.1.1/24。

SwitchA(config)# interface gigabitEthernet 0/1

SwitchA(config-if-GigabitEthernet 0/1)# no switchport

SwitchA(config-if-GigabitEthernet 0/1)# ip address 10.10.1.1 255.255.255.0

SwitchA(config-if-GigabitEthernet 0/1)# exit

  

# 将Switch A的端口GigabitEthernet 0/1配置为备份组10、20的监视接口，并配置Priority decrement为30。

SwitchA(config)# interface vlan 10

SwitchA(config-if-VLAN 10)# vrrp 10 track gigabitEthernet 0/1 30

SwitchA(config-if-VLAN 10)# exit

SwitchA(config)# interface vlan 20

SwitchA(config-if-VLAN 20)# vrrp 20 track gigabitEthernet 0/1 30

SwitchA(config-if-VLAN 20)# exit

  

# 配置端口GigabitEthernet 0/2和GigabitEthernet 0/3属于AP口，并配置AP口为trunk口。

SwitchA(config)# interface range gigabitEthernet 0/2-3

SwitchA(config-if-range)# port-group 1

SwitchA(config)# interface aggregateport 1

SwitchA(config-if-AggregatePort 1)# switchport mode trunk

```

  
  
  

## 配置ipv6的vrrp

  

```shell

interface VLAN 10

ipv6 address 2001:193:10::252/64 //配置本机ipv6地址

vrrp 10 ipv6 FE80::4 //配置虚拟链路本地地址

vrrp 10 ipv6 2001:193:10::254 //配置vrrp的虚拟ip

vrrp ipv6 10 priority 150 //配置优先级（越大越高）

vrrp ipv6 10 accept_mode //开启accept mode，接受处理vrrp报文

```

  

## 配置ipv6无状态获取地址

```shell

interface VLAN 10

ipv6 dhcp client ia //开启dhcp 客户端功能

ipv6 nd other-config-flag //启用client的无状态服务

  

clear ip dhcp binding * //执行以下命令来清除所有的DHCP绑定信息

```

  

## 配置ipv4DHCP中继

```shell

interface VLAN 10

ip helper-address 10.0.0.1 //设置VLAN10的dhcp服务器地址为10.0.0.1

```