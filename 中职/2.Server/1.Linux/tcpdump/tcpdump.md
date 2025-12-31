## 题目
- 在linux2上ssh到linux1主机，在linux1上使用tcpdump抓取该客户端的ssh过程的前5个数据包，以pcap格式存储到T0目录，文件名为:ssh-1.pcap。

## 解
```shell

tcpdump -i [网卡名称] port 22 -c 5 -w /tmp/skills_tmp/T0/ssh-1.pcap

#参数说明
-i any: 抓取所有网络接口的流量。

port 22: 抓取 SSH 流量（端口 22）。

-c 5: 仅抓取前 5 个数据包。

-w /tmp/skills_tmp/T0/ssh-1.pcap: 将抓到的数据包以 .pcap 格式存储到 T0 目录下。
```