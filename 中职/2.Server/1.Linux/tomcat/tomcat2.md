## 问题:
- 配置 linux3 和 linux4 为 tomcat 服务器，网站默认首页内容分别为“tomcatA”和“tomcatB”，仅使用域名访问 80 端口 http 和 443 端口 https；证书路径均为/etc/ssl/skills.jks。

## 解:
-配置tomcat9支持80端口监听
```shell
vim /usr/lib/systemd/system/tomcat.service
# Systemd unit file for default tomcat
#
# To create clones of this service:
# DO NOTHING, use tomcat@.service instead.

[Unit]
Description=Apache Tomcat Web Application Container
After=syslog.target network.target

[Service]
Type=simple
EnvironmentFile=/etc/tomcat/tomcat.conf
Environment="NAME="
EnvironmentFile=-/etc/sysconfig/tomcat
ExecStart=/usr/libexec/tomcat/server start
SuccessExitStatus=143
User=root                                       #将用户修改为root

[Install]
WantedBy=multi-user.target

systemctl daemon-reload
```

- 配置jdk
```shell
tar -zxvf jdk-20_linux-aarch64_bin.tar.gz 

vim /etc/profile
#在末尾添加

export JAVA_HOME=/opt/jdk-20.0.1
export PATH=$PATH:$JAVA_HOME/bin




```

- 配置tomcat
```shell
tar -zxvf apache-tomcat-11.0.0-M5.tar.gz

keytool -importkeystore  -srckeystore skills.pfx -destkeystore skills.jks -srcstoretype pkcs12 -deststoretype JKS

//配置tomcat的server.xml文件

vim /opt/tomcat/conf/server.xml

<Connector port="80" protocol="HTTP/1.1"
               connectionTimeout="20000"
               redirectPort="443" />
    <!-- A "Connector" using the shared thread pool-->
    <!--
    <Connector executor="tomcatThreadPool"
               port="80" protocol="HTTP/1.1"
               connectionTimeout="20000"
               redirectPort="443" />


    <Connector port="443" protocol="HTTP/1.1"
               maxThreads="150" SSLEnabled="true">
        <UpgradeProtocol className="org.apache.coyote.http2.Http2Protocol" />
        <SSLHostConfig>
            <Certificate certificateKeystoreFile="/etc/pki/tls/skills.jks"
                         certificateKeystorePassword="Key-1122" />
        </SSLHostConfig>
    </Connector>

<Engine name="Catalina" defaultHost="linux3.skills.lan">

      <!--For clustering, please take a look at documentation at:
          /docs/cluster-howto.html  (simple how to)
          /docs/config/cluster.html (reference documentation) -->
      <!--
      <Cluster className="org.apache.catalina.ha.tcp.SimpleTcpCluster"/>
      -->

      <!-- Use the LockOutRealm to prevent attempts to guess user passwords
           via a brute-force attack -->
      <Realm className="org.apache.catalina.realm.LockOutRealm">
        <!-- This Realm uses the UserDatabase configured in the global JNDI
             resources under the key "UserDatabase".  Any edits
             that are performed against this UserDatabase are immediately
             available for use by the Realm.  -->
        <Realm className="org.apache.catalina.realm.UserDatabaseRealm"
               resourceName="UserDatabase"/>
      </Realm>

      <Host name="linux3.skills.lan"  appBase="webapps"
            unpackWARs="true" autoDeploy="true"> 
      <Context path="" docBase="/html/" />
      </Host>
      
      <Host name="10.4.220.103"  appBase="随意指定一个空目录"             #不允许ip地址访问
            unpackWARs="true" autoDeploy="true" />


./shutdown.sh 
./startup.sh 
```

## 2023年国赛tomcat的RPM包和JDK源码包安装
### 本次配置顺序必须按照以下顺序

- 配置jdk
```shell
tar -zxvf jdk-20_linux-aarch64_bin.tar.gz 

vim /etc/profile
#在末尾添加

export JAVA_HOME=/opt/jdk-20.0.1
export PATH=$PATH:$JAVA_HOME/bin

- 安装tomcat包
- 国赛提供的tomcat安装包如下:
  - ecj-4.21-1.el9.noarch.rpm
  - tomcat-9.0.65-2.el9.noarch.rpm
  - tomcat-el-3.0-api-9.0.65-2.el9.noarch.rpm
  - tomcat-jsp-2.3-api-9.0.65-2.el9.noarch.rpm
  - tomcat-lib-9.0.65-2.el9.noarch.rpm
  - tomcat-native-1.2.36-1.el9.aarch64.rpm
  - tomcat-servlet-4.0-api-9.0.65-2.el9.noarch.rpm
  - tomcat-webapps-9.0.65-2.el9.noarch.rpm

```shell
#这里要特别说明，不能使用yum install tomcat* 来安装，这样安装会连带安装系统盘自带的jdk
#假设我们吧上面这些rpm包放在/opt/tomcat目录下，我们应该这么安装:
cd /opt/tomcat
rpm -ivh tomcat* --nodeps
```
- 配置tomcat

```shell
#配置tomcat，让它能使用jdk-20.0.1启动
vim /etc/tomcat/conf.d/java-9-start-up-parameters.conf 

#在末尾添加以下两行
export JAVA_HOME=/opt/jdk-20.0.1
export PATH=$PATH:$JAVA_HOME/bin

#修改启动项用户为root
#这步是为了让tomcat可以启动小于1023的端口，否则，tomcat将只能启动大于1023的端口
vim /usr/lib/systemd/system/tomcat.service

# Systemd unit file for default tomcat
#
# To create clones of this service:
# DO NOTHING, use tomcat@.service instead.

[Unit]
Description=Apache Tomcat Web Application Container
After=syslog.target network.target

[Service]
Type=simple
EnvironmentFile=/etc/tomcat/tomcat.conf
Environment="NAME="
EnvironmentFile=-/etc/sysconfig/tomcat
ExecStart=/usr/libexec/tomcat/server start
SuccessExitStatus=143
User=root     #将这行的用户修改为root

[Install]
WantedBy=multi-user.target
```
 
- 最后安装javapackages-filesystem和
```shell
yum install javapackages-filesystem javapackages-tools 

#这两个包在安装时会连带关联包一起安装
```

- 总结说明
- 只有按照以上方式安装才能让tomcat使用正确的jdk
- 安装完成后使用分别使用如下命令查看java版本和tomcat当前使用的jvm,都看到是20.0.1就行
```shell
java --version #查看java版本
```

