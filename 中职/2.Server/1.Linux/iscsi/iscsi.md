## 任务描述:请采用 iscsi，搭建存储服务。
- 为linux8 添加4块磁盘，每块磁盘大小为SG，创建Ivm 卷，卷组名称为vgl，逻辑卷名称为Ivl，容量为全部空间，格式化为 ext4 格式。使用/dev/vg1/Iv1 配置为iSCSI 目标服务器，为linux9提供iSCSI 服务。iSCSI 目标端的 wwn 为 iqn.2008-01.lan.skills:server,iSCSI 发起端的wwn为 iqn.2008-01.lan.skills:client1.
- 配置 linux9 为 iSCSI 客户端，实现 discoverychap和 sessionchap 双向认证，Target 认证用户名为IncomingUser，密码为 IncomingPass；Initiator认证用户名为 OutgoingUser，密码为 OutgoingPass。修改/etc/rc.d/rc.local 文件开机自动挂载iscsi 磁盘到/iscsi目录

## 解决有关rockylinux9.1没有/etc/iscsi/initiatorname.iscsi文件
```shell
systemctl restart iscsi
systemctl restart iscsid

重启完服务后会自动出现
```


## 创建lvm卷
```shell
pvcreate /dev/vdb /dev/vdc /dev/vdd /dev/vde

vgcreate vg1 /dev/vdb /dev/vdc /dev/vdd /dev/vde

lvcreate -L -n lv1 vg1

lvcreate -l +100%FREE -n lv1 vg1

mkfs.ext4 /dev/vg1/lv1
```

## iscsi目标端配置
```shell
yum install targetcli

targetcli

/backstores/block create disk_sdb /dev/vg1/lv1

/iscsi create iqn.2008-01.lan.skills:server

/iscsi> iqn.2008-01.lan.skills:server/tpg1/luns create /backstores/block/disk_sdb

/iscsi> iqn.2008-01.lan.skills:server/tpg1/acls create iqn.2008-01.lan.skills:client

/saveconfig

cd iscsi
#discovery_认证
set discovery_auth enable=1 userid=OutgoingUser password=OutgoingPass mutual_userid=IncomingUser mutual_password=IncomingPass

#session_认证
cd iscsi/iqn.2008-01.lan.skills:server/tpg1/acls/iqn.2008-01.lan.skills:client1/
set attributre authentication=1
set auth userid=OutgoingUser password=OutgoingPass mutual_userid=IncomingUser mutual_password=IncomingPass

#如果是rockylinux8的版本，下面的配置是不需要开的
cd iscsi/iqn.2008-01.lan.skills:server/tpg1  
set attributre authentication=1
```


## iscsi发起端配置
```shell
yum install iscsi-initiator*

systemctl start iscsid
systemctl start iscsi

vim /etc/iscsi/initiatorname.iscsi
iqn.2008-01.lan.skills:client

systemctl restart iscsid iscsi


iscsiadm -m discovery -t st -p 10.4.220.108
iscsiadm -m node -T iqn.2008-01.lan.skills:server -p 10.4.220.108 -l

#断开iscsi会话
#列出当前的 iSCSI 会话：
iscsiadm -m session

#断开特定的 iSCSI 会话
sudo iscsiadm -m node -T <TargetName> -p <TargetIP> -u

#注销所有 iSCSI 会话：
iscsiadm -m node -u


## discovery验证
vim /etc/iscsi/iscsid.conf
discovery.sendtargets.auth.authmethod = CHAP
discovery.sendtargets.auth.username = OutgoingUser
discovery.sendtargets.auth.password = OutgoingPass
discovery.sendtargets.auth.username_in = IncomingUser
discovery.sendtargets.auth.password_in = IncomingPass

#session验证：
node.session.auth.authmethod = CHAP
node.session.auth.username = OutgoingUser
node.session.auth.password = OutgoingPass
node.session.auth.username_in = IncomingUser
node.session.auth.password_in = IncomingPass


## iscsi开机挂载
vim /opt/iscsi.sh
#!/bin/bash
sleep 5
mount /dev/sda /shareiscsi

chmod 744 /opt/iscsi.sh


vim /etc/rc.d/rc.local
sh /opt/iscsi.sh

chmod o+x /etc/rc.d/rc.local   
```
