## 配置vsftp支持ssl
- 操作系统Rocky Linux 9.2
#### 生成一个TLS证书
#### 配置vsftpd.conf
```shell
sudo vim /etc/vsftpd/vsftpd.conf
rsa_cert_file=/etc/vsftpd/vsftpd.crt
rsa_private_key_file=/etc/vsftpd/vsftpd.key
ssl_enable=YES
```
#### 重启vsftpd服务
```
sudo systemctl restart vsftpd
```

#### 访问测试
```
#安装lftp工具
dnf install lftp

#访问测试
lftp -e 'set ftp:ssl-force true; set ftp:ssl-protect-data true; open ftp://ftp.example.com; user username password; ls; quit'
```