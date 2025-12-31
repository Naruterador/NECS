## 向防火墙中批量添加端口
```shell

for port in 22 23 24 80 110 445
do 
    firewall-cmd --zone=public --add-port=$port/tcp --permanent; 
done 
```
- 执行结束后重新加载防火墙
```shell
firewall-cmd --reload
```
