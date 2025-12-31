## 赛题:
- 任务描述：请采用 postfix 和 dovecot 搭建邮件服务器。
 - 配置 linux2 为 mail 服务器，安装 postfix 和 dovecot。
 - 仅支持 smtps 和 pop3s 连接。
 - 创建用户 mail1 和 mail2，向 all@skills.lan 发送的邮件，每个用户都会收到。
 - 使用本机测试。

## 解:
- **本题域名为skills.com**

- 1.安装postfix和pop3s
```shell
vim /etc/postfix/main.cf

myhostname = skills.com
mydomain = skills.com

#开启所有端口监听
inet_interfaces = all 

#邮件中继域名(多域名邮件互发)
relay_domains = $mydestinatioo

#允许转发的网段
mynetworks = 168.100.189.0/28, 127.0.0.0/8
mynetworks = 0.0.0.0/0  表示所有网段

#在配置文件末尾添加tls支持
smtpd_tls_security_level = may

#none：禁用TLS加密，服务器将不会尝试与客户端建立TLS连接。所有传输的邮件将以明文方式传输。这是默认值0。
#may：启用TLS加密，但不要求客户端使用TLS连接。服务器将尝试与客户端建立TLS连接，如果客户端不支持或不愿意使用TLS，服务器将以明文方式继续通信。
#encrypt：要求客户端使用TLS连接。服务器将尝试与客户端建立TLS连接，如果客户端不支持TLS或连接失败，服务器将拒绝连接。
#dane：要求客户端使用基于DANE（DNS-Based Authentication of Named Entities）的TLS连接。服务器将使用DANE验证证书，并要求客户端提供有效的DANE TLSA记录以建立连接。
#verify：要求客户端使用TLS连接，并验证客户端的证书。服务器将验证客户端证书的有效性，并拒绝连接无效或未提供证书的客户端。

#指定私钥和公钥路径
smtpd_tls_cert_file = /etc/ssl/certs/server.crt
smtpd_tls_key_file = /etc/ssl/private/server.key

#指定TLS会话缓存数据库文件
smtpd_tls_session_cache_database = btree:/var/lib/postfix/smtpd_tls_session_cache

#可选：指定缓存数据库的大小限制
smtpd_tls_session_cache_size = 10000

#配置邮箱路径
home_mailbox = Maildir/


########################################################################################################################################################################################

vim /etc/postfix/master.cf
```

- 配置邮件别名用于群发
- 用户名为user1,user2，别名用户为allmailuser
  ```shell
  vim /etc/aliases

  allmailuser: user1, user2
  ```

- 更新别名数据库
  `newaliases`

- 重启 Postfix
  `systemctl restart postfix`
