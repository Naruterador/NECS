## 问题（Linux版本为Rockylinux9.2）:
- 安装WEB服务。
- 服务以用户webuser系统用户运行。
- 限制WEB服务只能使用系统500M物理内存。
- 全站点启用TLS访问，使用本机上的“CSK Global Root CA”颁发机构颁发，网站证书信息如下：
  - C = CN
  - ST = China
  - L = BeiJing
  - O = skills
  - OU = Operations Departments
  - CN = *.chinaskills.com
- 客户端访问https时应无浏览器（含终端）安全警告信息。
- 当用户使用http访问时自动跳转到https安全连接。
- 搭建www.chinaskills.cn站点。
- 网页文件放在StorgeSrv服务器上。
- 在StorageSrv上安装MriaDB，在本机上安装PHP，发布WordPress网站。
- MariaDB数据库管理员信息：User: root/ Password: 000000。

## 解:
```shell
#服务以用户webuser系统用户运行。
useradd webuser

vi /etc/httpd/conf/httpd.conf

User webuser
Group webuser

#由于本题需要运行wordpress，需要安装php，但是如果直接像上面一样修改用户名和组，那么会出现如下报错:
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>503 Service Unavailable</title>
</head><body>
<h1>Service Unavailable</h1>
<p>The server is temporarily unable to service your
request due to maintenance downtime or capacity
problems. Please try again later.</p>
</body></html>
#出现这个报错，是因为php-fpm的权限问题，需要做如下配置修改:
chown webuser:webuser /run/php-fpm/www.sock
#修改完之后就能正常访问了

#########################################################################################

#网页文件放在StorgeSrv服务器上。
#本题的网页根目录是从StorgeSrv服务器上的NFS服务挂载过来的，其中NFS服务器的配置为:
vi /etc/exports
/var/www/html *(rw,sync,no_root_squash,no_subtree_check)

#子树检查（subtree check）：
#默认情况下，NFS 服务器在客户端请求访问某个文件时，会检查该文件是否位于导出目录的子树中。这种检查是为了确保客户端不会访问导出目录之外的文件。这种检查可以增加安全性，但也会增加一些额外的开销，尤其是在导出的目录层次结构比较复杂时。
#当使用 no_subtree_check 选项时，NFS 服务器将跳过这个子树检查步骤。这样可以提高性能，因为每次文件访问请求时都不需要进行额外的路径验证。缺点是，这会降低一些安全性，因为不再进行路径验证。

#no_subtree_check 的使用场景
#通常在以下情况下使用 no_subtree_check：
#你确信客户端只会访问导出目录中的文件。
#需要优化性能，减少额外的检查开销。
#导出目录结构比较简单，不需要额外的路径检查。
```