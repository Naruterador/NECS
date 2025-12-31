#### 题目需求：

- 【任务】VXLAN是一种网络虚拟化技术，可以改进大型云计算，可以穿透三层网络对二层进行扩展。

  - 在 linux3、linux4 之间创建简单的静态 VXLAN 互联，分别创建 vxlan 链接，name为 skills_vxlan10，vni:10，port:4789，linux3的skills_vxlan10的IP：172.16.32.30/24，linux4的 skills_vxlan10 的IP：172.16.32.40/24，在 linux3、linux4 之间可以互相 ping 通 skills_vxlan10 的 ip。
  - 在linux4上ping 172.16.32.30，在 Linux3 上使用 tcpdump 抓取与客户端 linux4 的的前 10 个数据包，以pcap格式存储到 /tmp目录，文件名为:vxlan-3.pcap。
- 配置步骤（第一部分）:

  - linux3配置:

  ```shell
  ip link add skills_vxlan10 type vxlan id 10 remote 192.168.1.2 dstport 4789 dev ens192 #创建vxlan网卡skills_vxlan10,vlanid为10  #remote参数后面跟的是物理网卡的IP地址
  
  ip link set skills_vxlan10 up                 #启动vxlan网卡
  ip addr add 172.16.32.30/24 dev skills_vxlan10 #为vxlan网卡分配地址

  ip route del default                               #删除默认路由为了可以在linux3和linux4之间通过vxlan隧道互访,不删会导致无法通信
  ip route add 172.16.32.40 dev skills_vxlan10       #增加一条隧道路由

  ping -I 172.16.32.30 172.16.32.40     #使用源地址ping



  ip route add default via 192.168.108.254   #由于删除了缺省导致外部主机无法ssh，可以添加本条缺省使得外机可以访问其中gw后面为网关地址
  ```

  - linux4配置

  ```shell
  ip link add skills_vxlan10 type vxlan id 10 remote 192.168.1.1 dstport 4789 dev
  ip link set skills_vxlan10 up
  ip addr add 172.16.32.40/24 dev skills_vxlan10

  ip route del default
  ip route add 172.16.32.30 dev skills_vxlan10

  ping -I 172.16.32.40 172.16.32.30

  ip route add default via 192.168.108.254
  ```
- 第二部分配置步骤:
- linux3的配置:

```shell
 #tcpdump -c 10 host 172.16.32.40 -w /tmp/vxlan-3.pcap
 tcpdump -i skills_vxlan10 -c 10 -w /tmp/vxlan-3.pcap
```

- 然后在 linux4 通过指令 ``ping -I 172.16.32.40 172.16.32.30``对面
