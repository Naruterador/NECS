## 题目
- 配置Linux-3为Tomcat服务器，tomcat安装目录为/usr/local/tomcat。将D:\soft\jndsjs 中全部微网站应用程序，复制到 tomcat 的相关目录，仅允许使用域名正常访问且页面信
息正确无误，http 访问自动跳转到 https，通过修改配置文件的方法，使用 443 端口；证书由 Linux-1 颁发，证书路径为<安装目录>/conf/tomcat.pfx，证书格式为 pfx。
- 利用 systemd 实现 tomcat 开机自启动，服务名称为 tomcat.service。

## 解
- 见目录下国赛选拔题tomcat1.pdf

- 创建开机自启服务
- 利用源码配置tomcat.service
```shell
cd /etc/systemd/system
cp syslog.service tomcat.service
vim tomcat.service 
# 修改以下内容
[Unit]
Description=tomcat Service
After=network.target network-online.target

[Service]
Type=forking
Environment=JAVA_HOME=/opt/jdk-17.0.4
ExecStart=/usr/local/tomcat/bin/startup.sh
ExecStop=/usr/local/tomcat/bin/shutdown.sh
Envivonment='JAVA_OPTS=-Diava.awt.headless=true'  # Java 应用程序在“无头模式”下运行，即无需显示器、键盘或鼠标的支持。这对于服务器环境特别有用，因为服务器通常没有图形界面。
User=root
Group=root

[Install]
WantedBy=multi-user.target
```