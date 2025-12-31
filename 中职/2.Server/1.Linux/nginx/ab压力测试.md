- 安装：
```shell
yum install httpd-tools -y
```

- 示例：1000 次请求、50 并发:
```shell
ab -n 1000 -c 50 http://你的服务器/index.php
```
