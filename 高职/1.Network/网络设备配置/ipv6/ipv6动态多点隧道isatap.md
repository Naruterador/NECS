## ipv6动态多点隧道isatap

  

```shell

  

#简要步骤

config terminal

interface tunnel tunnel-num

tunnel mode ipv6ip isatap

ipv6 address ipv6-prefix/prefix-length eui-64 //配置 IPv6 ISATAP 地址,注意指定使用 eui-64 关键字，这样将自动生成 ISATAP 的地址，在

SATAP 接口上配置的地址必须为 ISATAP 的地址。

tunnel source interface-type num //指定隧道引用的源接口号,被引用的接口上必须已经配置了 IPv4 的地址

no ipv6 nd suppress-ra //缺省情况下是禁止在接口上发送路由器公告报文的,使用该命令打开该功能从而允许 ISATAP主机进行自动配置

```