#### 聚合基础
- Teaming技术就是把同一台服务器上的多个物理网卡通过软件绑定成一个虚拟网卡，即：对于外部网络而言，这台服务器只有一个可用网卡。对于任何应用程序和网络，这台服务器只有一个网络链接或者说只有一个可以访问的IP地址。
  - 通过Teaming 技术做链路聚合，除了利用多网卡同时工作来提高网络速度以外，还有可以通过Teaming 实现不同网卡之间的负载均衡（Load balancing）和网卡冗余（Fault tolerance）,如同网络搭建中使用路由器实现负载均衡和备份一样。

- 网卡绑定bonding可以提高网络的冗余，保证网络可靠性，提高网络速度。为了提高网络容错或吞吐量，一般服务器都会采取多网卡绑定的策略，在RHEL5/RHEL6中使用的是Bonding。
- 用来实现链路聚合的功能，但是在RHEL7中，不会使用teaming替换bonding，它们是并存的，我们可以选择Teaming，也可以选Bonding。

- Team常用工作模式包含如下：
  - roundrobin 以轮循的模式传输所有端口的包；

  - activebakup 主备模式这是一个故障迁移程序，监控链接更改并选择活动的端口进行传输；

  - loadbalance 监控流量并使用哈希函数以尝试在选择传输端口的时候达到完美均衡。

#### 题目
- 在 Linux-6 主机添加一块网卡，创建聚合端口组，NAME 为 skills-team1，DEVICE 为 team1，聚合模式为 activebackup，聚合接口地址为第一块网卡获取的IP 地址。

#### 实验环境
- Rocky Linux 8.5

#### 实验步骤
```shell
#创建设备名称为team1，网卡名称为skills-team1的聚合卡，聚合模式为activebackup
nmcli connection add type team con-name team1 ifname skills-team1 config '{"runner":{"name":"activebackup"}}'
#将物理网卡添加进去聚合网卡team1
nmcli connection add type team-slave con-name team1-1 ifname ens192 master team1
nmcli connection add type team-slave con-name team1-2 ifname ens224 master team1
#为聚合网卡配置地址和网关
nmcli connection modify team1 ipv4.method manual ipv4.addresses 192.168.107.153/24 ipv4.gateway 192.168.107.254 autoconnect yes
#启动聚合卡
nmcli connection up team1-1
nmcli connection up team1-2
nmcli connection up team1
#查看聚合卡内容
teamdctl skills-team1 state