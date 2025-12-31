## mgre的nhrp配置

```shell

NHS（Next Hop Server，NHRP 服务器）

NHC（Next Hop Clients，NHRP 客户端）

NBMA地址（外部物理地址）

#每个子网包括至少一个 NHS，一个 NHS 可以为多个子网服务，接收来自多个 NHC 的请求和解析报文，每一个端系统都是一个 NHC

#NHRP 功能包括以下几个配置：

开启 NHRP 功能（必须）

配置静态的 ip-address 和 nbma-address 对应关系映射缓存（NHC 必须）

配置广播报文发送的地址（必须）

配置 NHS（NHC 必须）

  

Ruijie(config)#interface tunnel tunnel-number

//进入 tunnel 接口开始进行 NHRP 的配置。

Ruijie(config-Tunnel tunnel-number)#tunnel mode gre multipoint

//配置 tunnel 隧道的类型为 MGRE，该类型隧道用于组成网状拓扑，NHS 的 tunnel 隧道类型只能为 MGRE。

Ruijie(config-Tunnel tunnel-number)#ip nhrp network-id nhrp-number

//在 tunnel 接口上开启 NHRP 的功能

Ruijie(config-Tunnel tunnel-number)#ip nhrp map multicast dynamic

//发送方向也可以动态学习获得，配置动态学习命令，所有在该设备注册的 NBMA 地址都可以作为广播报文的发送地址

#NHC配置：

Ruijie(config-Tunnel tunnel-number)#ip nhrp map multicast nbma-address

//配置通过 tunnel 隧道发送的广播和多播报文的静态的发送方向。地址为 NBMA 地址，可以配置多个。

Ruijie(config-Tunnel tunnel-number)#ip nhrp map ip-address nbma-address

//配置 nhs 的静态 ip 和 nbma 的地址映射关系。

ip nhrp nhs nhs-address

//配置 nhc 设备需要注册 nhs 的地址，发送注册请求报文。

Ruijie(config-Tunnel tunnel-number)#ip ospf network point-to-multipoint

//nbma网络需要设置ospf状态，设置为点到多点模式