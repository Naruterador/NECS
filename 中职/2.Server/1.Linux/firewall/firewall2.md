## 省赛题解析
### 问题：
- 在 Linux-6 、Linux-7 主机上，在 nftables 中创建表 Skills_IP6 ，在 Skills_IP6 中创建链 chain_input，在链中添加 rule 方式， 实现拒绝所有 ipv6 访问本机的 80、1020、21端口。

### 解:
```shell
nft add table ip6 Skills_IP6 #创建表

nft add chain ip6 Skills_IP6 chain_input '{ type filter hook input priority 0;policy drop;}' #增加链并且将策略配置为drop;

nft delete chain ip6 Skills_IP6 chain_input #删除链

nft add rule ip6 Skills_IP6 chain_input tcp dport 80 reject
nft add rule ip6 Skills_IP6 chain_input tcp dport 1020 reject
nft add rule ip6 Skills_IP6 chain_input tcp dport 21 reject
nft add rule ip6 Skills_IP6 chain_input udp dport 80 reject
nft add rule ip6 Skills_IP6 chain_input udp dport 1020 reject
nft add rule ip6 Skills_IP6 chain_input udp dport 21 reject

nft list table ip6 Skills_IP6

systemctl restart nftables
```