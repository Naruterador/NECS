## 问题:
- 配置 linux1 为 Apache2 服务器，使用 skills.lan 或any.skills.lan（any 代表任意网址前缀，用 linux1.skills.lan 和web.skills.lan 测试）访问时，自动跳转到 www.skills.lan。禁止使用 IP 地址访问，默认首页文档/var/www/html/index.html 的内容为"apache"。

## 解:
- 配置httpd.conf
```shell
ServerTokens Prod
ServerSignature Off
```

- 配置ssl.conf文件
```shell
vim /etc/httpd/conf.d/ssl.conf

DocumentRoot "/var/www/html"
ServerName www.skills.lan:443
rewriteEngine on
rewriteCond %{HTTP_HOST} !^www.skills.lan [NC]
rewriteRule ^/(.*)$ https://www.skills.lan [R=301,L]
# Use separate log files for the SSL virtual host; note that LogLevel
# is not inherited from httpd.conf.
ErrorLog logs/ssl_error_log
TransferLog logs/ssl_access_log
LogLevel warn

<Directory "/var/www/html">
    SSLOptions +StdEnvVars
allowoverride none
require all granted
</Directory>


openssl x509 -in /etc/pki/CA/cacert.pem >> /etc/pki/tls/certs/ca-bundle.crt   #将CA根证书导入本地证书颁发机构


SSLCertificateFile /etc/ssl/skills.crt
SSLCertificateKeyFile /etc/ssl/skills.key

#指向全局CA证书（包括所有CA证书颁发机构）
SSLCACertificateFile /etc/pki/tls/certs/ca-bundle.crt

#指向单一的一个证书颁发机构
SSLCACertificateFile /etc/pki/CA/cacert.pem



SSLVerifyClient require
SSLVerifyDepth  10


#转发配置
vim /etc/httpd/conf/httpd.conf
<virtualhost *:80>
documentroot "/var/www/html"
servername www.skills.lan
rewriteEngine on
rewriteCond %{SERVER_PORT} 80
rewriteRule ^/(.*)$ https://www.skills.lan [R=301,L]
<directory "/var/www/html">
allowoverride none
require all granted
</directory>
</virtualhost>

#禁止IP地址访问
<virtualhost *:80>
servername 10.6.220.101
<location />
order allow,deny
deny from all
</location>
</virtualhost>

<virtualhost *:443>
servername 10.6.220.101
<location />
order allow,deny
deny from all
</location>
</virtualhost>
```
## 其他跳转方式
- 创建虚拟主机
```c
<virtualhost *:80>
redirect "/wordpress" https://linux5.skills.com/wordpress
</virtualhost>

#配置解释：
#当访问 http://linux5.skills.com/wordpress 时，会自动跳转到https://linux5.skills.com/wordpress

#前面的 "/wordpress" 表是访问路径，当配置为 "/" 时表示主目录


```