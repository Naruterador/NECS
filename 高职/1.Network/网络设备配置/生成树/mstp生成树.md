```shell

spanning-tree mst configuration //进入实例配置界面

revision 1 //调整版本（所有设备需版本相同，默认为0）

name ruijie //调整实例名称（所有设备需名称相同）

!

spanning-tree //开启功能

spanning-tree priority 8192 //调整设备优先级（默认32768，越小越大）

  

interface GigabitEthernet 0/13

switchport protected //开启安全端口（边缘端口）

spanning-tree bpduguard enable //打开bpdu防护功能

spanning-tree portfast //打开portfast防护功能

switchport port-security //打开端口保护

```