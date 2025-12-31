#### 6028和6028pro组播配置
```shell
AC#show run
!
no service password-encryption
!
hostname AC
sysLocation China
sysContact 400-810-9119
!
username admin privilege 15 password 0 admin
!
!
no logging flash
!
vlan 1;100
!
vlan 1002   #配置组播Vlan（三层）
 multicast-vlan
 multicast-vlan association 100
!
multicast destination-control
!
Interface Ethernet1/0/1
 switchport access vlan 100
!
Interface Ethernet1/0/2
!
Interface Ethernet1/0/3
!
Interface Ethernet1/0/4
!
Interface Ethernet1/0/5
!
Interface Ethernet1/0/6
!
Interface Ethernet1/0/7
!
Interface Ethernet1/0/8
!
Interface Ethernet1/0/9
!
Interface Ethernet1/0/10
!
Interface Ethernet1/0/11
!
Interface Ethernet1/0/12
!
Interface Ethernet1/0/13
!
Interface Ethernet1/0/14
!
Interface Ethernet1/0/15
!
Interface Ethernet1/0/16
!
Interface Ethernet1/0/17
!
Interface Ethernet1/0/18
!
Interface Ethernet1/0/19
!
Interface Ethernet1/0/20
!
Interface Ethernet1/0/21
!
Interface Ethernet1/0/22
!
Interface Ethernet1/0/23
!
Interface Ethernet1/0/24
 switchport access vlan 1002
!
Interface Ethernet1/0/25
!
Interface Ethernet1/0/26
!
Interface Ethernet1/0/27
!
Interface Ethernet1/0/28
!
interface Vlan100
 ip address 192.168.100.1 255.255.255.0 #组播客户端接口
!
interface Vlan1002
 ip address 10.10.20.2 255.255.255.0 #组播源的进接口
!
ip igmp snooping
ip igmp snooping vlan 1002
!
router ospf 1
 network 10.10.20.0 0.0.0.255 area 0
 network 192.168.100.0 0.0.0.255 area 0
```