#### 主区域区域文件
```shell
zone "skills.lan" IN {
        type master;
        file "named.skills";
        allow-transfer { 10.4.220.102; };
        allow-update { none; };
};

zone "220.4.10.in-addr.arpa" IN {
        type master;
        file "named.10";
        allow-transfer { 10.4.220.102; };
        allow-update { none; };
};
```

#### 正向配置文件
```shell
TTL 1D
@       IN SOA  @ rname.invalid. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
@       A       10.4.220.101
        NS      linux1.skills.lan.
        NS      linux2.skills.lan.
linux1  A       10.4.220.101
linux2  A       10.4.220.102
@        MX  10  linux2.skills.lan.
linux3  A       10.4.220.103
linux4  A       10.4.220.104
linux5  A       10.4.220.105
linux6  A       10.4.220.106
linux7  A       10.4.220.107
linux8  A       10.4.220.108
linux9  A       10.4.220.109
web     A       10.4.220.101
www     A       10.4.220.101
tomcat  A       10.4.220.102
```



####  反向配置文件
```shell
$TTL 1D
@       IN SOA  @ rname.invalid. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      @
@       A       10.4.220.101
@       PTR     linux1.skills.lan.
@       PTR     linux2.skills.lan.

101     PTR     linux1.skills.lan.
102     PTR     linux2.skills.lan.
103     PTR     linux3.skills.lan.
104     PTR     linux4.skills.lan.
105     PTR     linux5.skills.lan.
106     PTR     linux6.skills.lan.
107     PTR     linux7.skills.lan.
108     PTR     linux8.skills.lan.
109     PTR     linux9.skills.lan.

101     PTR     skills.lan.
101     PTR     www.skills.lan.
101     PTR     web.skills.lan.
102     PTR     tomcat.skills.lan.
```


### 辅助区域区域文件
```shell
zone "skills.lan" IN {
        type slave;
        file "named.skills";
        masters { 10.4.220.101; };
};

zone "220.4.10.in-addr.arpa" IN {
        type slave;
        file "named.10";
        masters { 10.4.220.101; };
};
```