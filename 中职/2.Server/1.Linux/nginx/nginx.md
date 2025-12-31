## 问题:
- 配置 linux2 为 nginx 服务器，默认文档 index.html 的内容为“hellonginx”；仅允许使用域名访问，http 访问自动跳转到 https。

## 解:
- 配置nginx.conf
```shell
vim /etc/nginx/nginx.conf

server {
        listen       80;
        server_name  linux2.skills.lan;
        root         /usr/share/nginx/html;
        if ($host != linux2.skills.lan) {
        return 403;
        }
        return 301 https://$server_name$request_uri;
        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }


server {
        listen       443 ssl http2;
        server_name  linux2.skills.lan;
        root         /usr/share/nginx/html;
        
        if ($host != linux2.skills.lan) {
        return 403;
        }
        
        ssl_certificate "/etc/pki/tls/skills.crt";
        ssl_certificate_key "/etc/pki/tls/skills.key";
        ssl_session_cache shared:SSL:1m;
        ssl_session_timeout  10m;
        ssl_ciphers PROFILE=SYSTEM;
        ssl_prefer_server_ciphers on;
}
```


## 问题:
- 利用 nginx 反向代理，实现 linux3 和 linux4 的 tomcat 负载均衡，通过 https://tomcat.skills.lan 加密访问 Tomcat，http 访问通过 301 自动跳转到 https
```shell
vim /etc/nginx/nginx.conf

upstream pools {
        server linux3.skills.lan:443;
        server linux4.skills.lan:443;
}

server {
        listen       80;
        server_name  tomcat.skills.lan;
        if ($host != tomcat.skills.lan) {
        return 403;
        }
        return 301 https://$server_name$request_uri;
}

server {
        listen       443 ssl http2;
        server_name  tomcat.skills.lan;
        if ($host != tomcat.skills.lan) {
        return 403;
        }
        ssl_certificate "/etc/ssl/skills.crt";
        ssl_certificate_key "/etc/ssl/skills.key";
        location / {
        proxy_pass https://pools;
        }
}
```
