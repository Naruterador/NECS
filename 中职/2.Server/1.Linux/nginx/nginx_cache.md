## Nginx配置缓存

- 缓存可以非常有效的提升性能，因此不论是客户端（浏览器），还是代理服务器（ Nginx ），乃至上游服务器都多少会涉及到缓存。可见缓存在每个环节都是非常重要的。下面让我们来学习 Nginx 中如何设置缓存策略。


+ proxy_cache
  + 存储一些之前被访问过、而且可能将要被再次访问的资源，使用户可以直接从代理服务器获得，从而减少上游服务器的压力，加快整个访问速度。
  + 语法：proxy_cache zone | off ; # zone 是共享内存的名称 
  + 默认值：proxy_cache off; 
  +上下文：http、server、location


+ proxy_cache_path
  + 设置缓存文件的存放路径。
  + 语法：proxy_cache_path path [level=levels] ...可选参数省略，下面会详细列举
  + 默认值：proxy_cache_path off
  + 上下文：http
  + 参数含义：
    + path 缓存文件的存放路径；
    + level path 的目录层级；
    + keys_zone 设置共享内存；
    + inactive 在指定时间内没有被访问，缓存会被清理，默认10分钟；

+ proxy_cache_key
  + 设置缓存文件的 key 。
  + 语法：proxy_cache_key
  + 默认值：proxy_cache_key $scheme$proxy_host$request_uri;
  + 上下文：http、server、location

+ proxy_cache_valid
  + 配置什么状态码可以被缓存，以及缓存时长。
  + 语法：proxy_cache_valid [code...] time;
  + 上下文：http、server、location
  + 配置示例：proxy_cache_valid 200 304 2m;; # 说明对于状态为200和304的缓存文件的缓存时间是2分钟

+ proxy_no_cache
  + 定义相应保存到缓存的条件，如果字符串参数的至少一个值不为空且不等于“ 0”，则将不保存该响应到缓存。
  + 语法：proxy_no_cache string;
  + 上下文：http、server、location 
  + 示例：proxy_no_cache $http_pragma    $http_authorization;

+ proxy_cache_bypass
  + 定义条件，在该条件下将不会从缓存中获取响应。
  + 语法：proxy_cache_bypass string;
  + 上下文：http、server、location
  + 示例：proxy_cache_bypass $http_pragma    $http_authorization;

+ upstream_cache_status 变量
  + 它存储了缓存是否命中的信息，会设置在响应头信息中，在调试中非常有用。
  + MISS: 未命中缓存
  + HIT： 命中缓存
  + EXPIRED: 缓存过期
  + STALE: 命中了陈旧缓存
  + REVALIDDATED: Nginx验证陈旧缓存依然有效
  + UPDATING: 内容陈旧，但正在更新
  + BYPASS: X响应从原始服务器获取


## 配置实例
##### 我们把 121.42.11.34 服务器作为上游服务器，做如下配置（ /etc/nginx/conf.d/cache.conf ）：

```c
server {
  listen 1010;
  root /usr/share/nginx/html/1010;
  location / {
   index index.html;
  }
}
 
server {
  listen 1020;
  root /usr/share/nginx/html/1020;
  location / {
   index index.html;
  }
}
```

##### 把 121.5.180.193 服务器作为代理服务器，做如下配置（ /etc/nginx/conf.d/cache.conf ）：

```c
proxy_cache_path /etc/nginx/cache_temp levels=2:2 keys_zone=cache_zone:30m max_size=2g inactive=60m use_temp_path=off;
 
upstream cache_server{
  server 121.42.11.34:1010;
  server 121.42.11.34:1020;
}
 
server {
  listen 80;
  server_name cache.lion.club;
  location / {
    proxy_cache cache_zone; # 设置缓存内存，上面配置中已经定义好的
    proxy_cache_valid 200 5m; # 缓存状态为200的请求，缓存时长为5分钟
    proxy_cache_key $request_uri; # 缓存文件的key为请求的URI
    add_header Nginx-Cache-Status $upstream_cache_status # 把缓存状态设置为头部信息，响应给客户端
    proxy_pass http://cache_server; # 代理转发
  }
}
```
##### 缓存就是这样配置，我们可以在 /etc/nginx/cache_temp 路径下找到相应的缓存文件。
+ 对于一些实时性要求非常高的页面或数据来说，就不应该去设置缓存，下面来看看如何配置不缓存的内容。

```c
...
 
server {
  listen 80;
  server_name cache.lion.club;
  # URI 中后缀为 .txt 或 .text 的设置变量值为 "no cache"
  if ($request_uri ~ \.(txt|text)$) {
   set $cache_name "no cache"
  }
  
  location / {
    proxy_no_cache $cache_name; # 判断该变量是否有值，如果有值则不进行缓存，如果没有值则进行缓存
    proxy_cache cache_zone; # 设置缓存内存
    proxy_cache_valid 200 5m; # 缓存状态为200的请求，缓存时长为5分钟
    proxy_cache_key $request_uri; # 缓存文件的key为请求的URI
    add_header Nginx-Cache-Status $upstream_cache_status # 把缓存状态设置为头部信息，响应给客户端
    proxy_pass http://cache_server; # 代理转发
  }
}
```