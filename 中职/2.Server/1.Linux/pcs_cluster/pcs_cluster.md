## 题目
- 配置 Linux-6 和 Linux-7 为 packmarker 集群，集群名称为 lincluster，Linux-6 为主服务器，Linux-7 为备份服务器。提供 http 服务，域名为 www3.skills.com，网站目录
/var/www/html，网站主页 index.html 的内容为“Linux 集群网站”。IP 资源名称为 vip，虚拟 IP 为 10.10.70.90；站点文件系统资源名称为 site，物理目录为 lv1；监视资源名称
为 webstatus，配置文件为/etc/httpd/conf/httpd.conf

## 解:

- 安装pcs(Linux6和Linux7上都要安装)
`yum install pcs fence-agents-all pcp-zeroconf pacemaker`

- 为集训用户设置密码(Linux6和Linux7上都要配置)
`passwd hacluster`

- 验证集群节点主机名(只在Linux6配置)
```shell
pcs host auth linux6.skills.com
pcs host auth linux7.skills.com
```

- 出现如下配置表示集群验证成功
```shell
linux6.skills.com: Authroized
linux7.skills.com: Authroized
```

- 创建集群名称为lincluster(只在Linux6配置)
`pcs cluster setup lincluster --start linux6.skills.com linux7.skills.com`

- 配置集群服务开机自启动(只在Linux6配置)
`pcs cluster enable --all`

- 查看集群状态是否正常(只在Linux6配置)
`pcs cluster status`

- 配置集群属性stonith-enabled
- 在 Pacemaker 集群管理系统中，stonith-enabled 是一个集群属性，用于控制 STONITH（Shoot The Other Node In The Head）的启用状态。
yum i
  - STONITH：STONITH 是一种防止集群中的数据损坏和数据不一致的机制。它的主要功能是，当某个节点失去响应或状态异常时，通过远程“强制重启”或“电源关闭”等方式，将该节点从集群中移除，以确保集群数据的一致性。
  - 禁用 STONITH：通过将 stonith-enabled 设置为 false，可以关闭这种节点隔离功能。这样，集群在检测到节点失效时不会自动对其进行强制重启或移除，而是继续运行其它节点。
  - 使用风险：禁用 STONITH 后，如果出现节点异常，可能会带来数据不一致的风险。因此在生产环境中，通常建议开启 STONITH 以确保数据安全。

- 分别在linux6和linux7上安装apache
`yum install httpd`

- 在linux6和linux7上启动apache,但不是以systemctl的方式启动
`/bin/systemctl reload httpd.service > /dev/null 2>/dev/null || true`
- /bin/systemctl reload httpd.service：这是重新加载 Apache HTTP Server (httpd) 服务的命令。reload 操作会在不完全重启的情况下应用配置更改，保持当前连接不中断。
  - \> /dev/null：将标准输出（正常输出）重定向到 /dev/null，即丢弃所有输出。
  - 2> /dev/null：将标准错误输出（错误信息）也重定向到 /dev/null，避免输出错误信息。
  - || ture：表示如果 systemctl reload 命令执行失败（返回非零状态码），则用 true 来保证命令整体的返回状态为成功。这样不会因为 reload 命令失败而触发脚本的错误处理机制。


`/usr/sbin/httpd -f /etc/httpd/conf/httpd.conf -c "PidFile /var/run/httpd.pid" -k graceful > /dev/null 2>/dev/null || true`
- /usr/sbin/httpd -f /etc/httpd/conf/httpd.conf：这是启动 Apache HTTP Server 的命令。-f 选项指定了 Apache 的配置文件路径（这里是 /etc/httpd/conf/httpd.conf）。
- -c "PidFile /var/run/httpd.pid"：-c 选项用于在启动时添加额外的配置指令，这里是指定 PID 文件的位置为 /var/run/httpd.pid。这可以帮助管理进程，尤其是在自定义启动脚本中。
- -k graceful：指定使用“graceful”模式重启 Apache，这意味着服务器会在保持现有连接不中断的情况下重新加载配置文件。新的连接将使用更新后的配置，而旧连接会继续使用旧配置直到完成。
- > /dev/null：将标准输出重定向到 /dev/null，即丢弃所有正常输出。
- 2> /dev/null：将标准错误输出重定向到 /dev/null，即丢弃所有错误信息。
- || true：即使命令执行失败（返回非零状态码），使用 true 使整个命令返回成功（退出状态 0），确保不会触发脚本的错误处理机制。


- 将网页内容放到iscsi共享空间中(只在Linux6配置)
```shell
mount /dev/mapper/vg1/lv1 /var/www
mkdir /var/www/html
echo "Linux 集群网站" > /var/www/html/index.html
umount /var/www
```

- 创建文件资源(只在Linux6配置)
`pcs resource create site Filesystem device="/dev/mapper/vg1/lv1" directory="/var/www/" fstype="ext4" --group apache`
- pcs resource create site Filesystem：使用 pcs 命令创建名为 site 的文件系统资源。Filesystem 是资源的类型，表示这是一个文件系统资源。
- device="/dev/mapper/vg1/lv1"：指定文件系统的设备路径，通常是逻辑卷或分区。在此例中，是位于 /dev/mapper/vg1/lv1 的逻辑卷。
- directory="/var/www/html"：指定文件系统的挂载点，即将设备 /dev/mapper/vg1/lv1 挂载到 /var/www 目录下。
- fstype="ext4"：指定文件系统的类型为 ext4。
- --group apache：将创建的 site 资源加入到 apache 资源组中。这样做的好处是，apache 资源组中的资源会一起启动、停止和迁移，便于管理。

- 创建IP资源(只在Linux6配置)
`pcs resource create vip IPaddr2 ip=10.10.70.90 cidr_netmask=24 --group apache`
- pcs resource create vip IPaddr2：使用 pcs 命令创建名为 vip 的 IP 资源。IPaddr2 是资源的类型，表示这是一个 IP 地址资源。



- 创建监视资源
  - 分别在Linux6和Linux7上配置apache内置监视资源的localtion
```shell
vim /etc/httpd/conf/httpd.conf
#添加如下内容
<Location /server-status>
SetHandler server-status
Require local
</Location>

#只在Linux6上配置如下指令
pcs resource create webstatus apache configfile="/etc/httpd/conf/httpd.conf" statusurl="http://127.0.0.1/server-status" --group apache
# pcs resource create webstatus apache：使用 pcs 命令创建名为 webstatus 的 Apache HTTP Server 资源。apache 是资源的类型，表示这是一个 Apache HTTP Server 资源。

pcs resource create webstatus ocf:heartbeat:apache configfile=/etc/httpd/conf/httpd.conf #启动资源集群后可以apache服务会自动启动
```
- 在Linux6上查看集群状态
`pcs status`