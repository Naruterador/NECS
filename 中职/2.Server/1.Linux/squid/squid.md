## 问题:
- 任务描述：为提高Web服务器具有较高的并发，使用Squid服务作为缓存， 降低linux1 Web服务器运行压力。
 - 为linux8服务器安装配置Squid服务，允许所有人访问，外网监听端口为443。
 - 采用ufs缓存机制，缓存目录设置为/cache,目录容量为5GB，L1及L2级目录数量分别为16及256，定义单个缓存文件大小为512MB；。
 - 指定目标服务器地址为linux1的IP地址，后端端口为443，别名为nvsc，允许最大连接数为20、权值为4。
 - 当用户请求https://www3. skills.lan时，转发到名为nvsc的真实服务器上。


## 解:
- 首先申请证书squid.key,squid.crt
- 配置/etc/squid/squid.conf
```c
//反向代理

https_port 443 accel vhost cert=/etc/ssl/squid.crt key=/etc/ssl/squid.key  //如果改为http_port则访问时只能使用http://ip:443来访问

cache_dir ufs /cache 5000 16 256 //开启ufs缓存
cache_mem 256 MB //缓存占内存大小
maximum_object_size 512MB       //用于定义Squid缓存中可以存储的单个对象的最大大小

http_access allow all
cache_peer linux2.skills.com parent 443 0 no-query originserver login=PASS ssl sslflags=DONT_VERIFY_PEER name=nvsc weight=4 max-conn=20

//no-query：这个参数指定了Squid是否应该将请求发送到源服务器。如果设置为no-query，则Squid将不会向源服务器发送请求，而是仅使用缓存中的数据响应客户端请求。这在特定的配置场景下很有用，例如用作反向代理服务器或CDN。
//originserver：这个参数指定Squid将直接与源服务器建立连接，而不是通过其他代理服务器。它告诉Squid不要再继续进行代理链路。
//login=PASS：这个参数指定Squid使用基本身份验证（Basic Authentication）来与源服务器进行登录。它表示Squid将向源服务器发送包含用户名和密码的登录凭据，以便与源服务器建立受保护的连接。
//ssl：这个参数指定Squid与源服务器之间的通信使用SSL（Secure Sockets Layer）或其继任者TLS（Transport Layer Security）协议进行加密。它确保通过互联网传输的数据在传输过程中是安全的。
//sslflags=DONT_VERIFY_PEER：这个参数指定Squid在与源服务器立SSL连接时不验证对方的证书。它将跳过对证书的验证步骤，不会验证源服务器的身份。这通常在测试或开发环境中使用，因为它可能会导致安全风险。在生产环境中，建议进行证书验证以确保连接的安全性。

``

