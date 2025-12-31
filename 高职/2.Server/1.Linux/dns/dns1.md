## 高职DNS配置
- 配置要求:
  - 服务器ISPSrv工作任务:
    - 安装BIND9
    - 配置为DNS根域服务器
    - 其他未知域名解析，统一解析为该本机IP
    - 创建正向区域“chinaskills.cn”
    - 类型为Slave
    - 主服务器为“AppSrv”
  - 服务器AppSrv上的工作任务:
    - 为chinaskills.cn域提供域名解析
    - 为www.chinaskills.cn提供解析
    - 启用内外网解析功能，当内网客户端请求解析的时候，解析到对应的内部服务器地址，当外部客户端请求解析的时候，请把解析结果解析到提供服务的公有地址
    - 请将IspSrv作为上游DNS服务器，所有未知查询都由该服务器处理


```shell
#配置ISPSrv，满足其他未知域名解析，统一解析为该本机IP
vim /etc/named.conf

zone "." IN {
        type master;
        file "catch-all.db";
};


cd /var/named
cp -p named.localhost catch-all.db

vim /var/named/catch-all.db
$TTL 1D
@       IN SOA  @ rname.invalid. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      localhost.
*       A       172.16.81.201



#配置AppSrv,满足将IspSrv作为上游DNS服务器，所有未知查询都由该服务器处理
vim /etc/named.conf

options {
        listen-on port 53 { any; };
        listen-on-v6 port 53 { ::1; };
        forwarders { 172.16.81.201; };    #添加转发器，指向ISPSrv
        directory       "/var/named";
...
```