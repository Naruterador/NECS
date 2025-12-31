## 配置snmp

  

```shell

enable service snmp-agent //启动 Agent 功能。

snmp-server user admin 1 v2c //配置用户信息

snmp-server group 1 v2c read public write Test //设置用户组，绑定团体

snmp-server host 172.16.0.254 traps version 2c Test //设置发送trap消息的NMS地址

snmp-server host 172.16.0.254 traps version 2c public

snmp-server community Test rw //建立团体

snmp-server community public ro

```

  

## 配置snmpv3

  

```shell

snmp-server view default 1.1.1.1 include //建立default视图（default为默认视图）

snmp-server view default 1.1.1.1.1.1 exclude

snmp-server user Admin!@# test v3 encrypted auth sha2-256 123 priv aes128 123

snmp-server group test v3 priv read default write default

snmp-server logging set-operation

snmp-server host 172.16.0.254 traps version 3 priv Admin!@#

snmp-server enable traps

no snmp-server enable version v1

no snmp-server enable version v2c

snmp-server enable version v3

```