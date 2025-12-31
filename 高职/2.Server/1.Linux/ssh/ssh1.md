## 问题（使用系统版本为rockylinux9.2）
- 工作端口为2021。
- 只允许用户user01，密码ChinaSkill23登录到router。其他用户（包括root）不能登录，创建一个新用户，新用户可以从本地登录，但不能从ssh远程登录。
- 通过ssh登录尝试登录到RouterSrv，一分钟内最多尝试登录的次数为3次，超过后禁止该客户端网络地址访问ssh服务。
- 记录用户登录的日志到/var/log/ssh.log，日志内容要包含：源地址，目标地址，协议，源端口，目标端口。

```shell
#修改端口为2021
vi /etc/ssh/sshd_config.d/50-redhat.conf

Port 2021

#重启服务
systemctl reload sshd


#- 只允许用户user01，密码ChinaSkill23登录到router。其他用户（包括root）不能登录，创建一个新用户，新用户可以从本地登录，但不能从ssh远程登录。
useradd user01

vi /etc/ssh/sshd_config.d/50-redhat.conf
PermitRootLogin no
AllowUsers user01

systemctl reload sshd

#通过ssh登录尝试登录到RouterSrv，一分钟内最多尝试登录的次数为3次，超过后禁止该客户端网络地址访问ssh服务。
vi /etc/ssh/sshd_config.d/50-redhat.conf

MaxAuthTries 6   #这个参数要说明下，在rockylinux9.2下，如果我配置为3登陆失败次数为0，但是如果我配置为6，则能满足3次登陆失败
LoginGraceTime 1m

#记录用户登录的日志到/var/log/ssh.log，日志内容要包含：源地址，目标地址，协议，源端口，目标端口。
vi /etc/ssh/sshd_config.d/50-redhat.conf

SyslogFacility local1
LogLevel VERBOSE

##################################################################################################################
# SyslogFacility 参数说明:
#auth：安全/授权消息（例如，authpriv.*）
#authpriv：更加严格的安全/授权消息
#cron：cron守护程序的消息
#daemon：其他守护程序的消息
#kern：内核消息
#lpr：打印系统消息
#mail：邮件系统消息
#news：新闻组消息
#syslog：syslog自身的消息
#user：一般用户级别消息
#uucp：UUCP系统消息
#local0到local7：本地设施，用于用户自定义消息

# LogLevel 参数说明:
#QUIET：最小化日志记录，只记录最重要的消息。
#FATAL：仅记录致命错误消息。
#ERROR：记录错误消息。
#INFO：记录一般信息消息。
#VERBOSE：记录详细信息消息。
#DEBUG：记录调试级别的详细信息消息。
#DEBUG1：记录调试级别 1 的详细信息消息。
#DEBUG2：记录调试级别 2 的详细信息消息。
#DEBUG3：记录调试级别 3 的详细信息消息。

##################################################################################################################

vi /etc/rsyslog.conf
local1.*                                              /var/log/ssh.log

#重启日志服务器
systemctl restart rsyslog
```
