## 问题:
- 系统安装
  - 通过PC1 web连接Server2，给Server2安装rocky-arm64 CLI系统（语言为英文）。
  - 配置Server2的IPv4地址为10.2.220.100/24。
  - 安装qemu和virt-install。
  - 安装linux1，系统为rocky-arm64 CLI，网卡、硬盘、显示驱动均为virtio，网络模式为桥接模式。
  - 关闭linux1，给linux1创建快照，快照名称为linux-snapshot。
  - 根据linux1克隆虚拟机linux2-linux9。
  - 创建rocky-arm64虚拟机，虚拟机硬盘文件保存在默认目录，名称为linuxN.qcow2(N表示虚拟机编号1-9，如虚拟机linux1的硬盘文件为linux1.qcow2,虚拟机linux2的硬盘文件为linux2.qcow2),虚拟机信息如下：

|虚拟机名称|vcpu|内存|硬盘|IPv4地址|完全合格域名|
|---|---|---|---|---|---|
|linux1|2|4096MB|40GB|10.2.220.101/24|linux1.skills.lan|
|linux2|2|4096MB|40GB|10.2.220.102/24|linux2.skills.lan|
|linux3|2|4096MB|40GB|10.2.220.103/24|linux3.skills.lan|
|linux4|2|4096MB|40GB|10.2.220.104/24|linux4.skills.lan|
|linux5|2|4096MB|40GB|10.2.220.105/24|linux5.skills.lan|
|linux6|2|4096MB|40GB|10.2.220.106/24|linux6.skills.lan|
|linux7|2|4096MB|40GB|10.2.220.107/24|linux7.skills.lan|
|linux8|2|4096MB|40GB|10.2.220.108/24|linux8.skills.lan|
|linux9|2|4096MB|40GB|10.2.220.109/24|linux9.skills.lan|

---

## 解:


#### 安装qemu和virt-install

```shell
#挂载光盘作为安装源

#使用一下指令安装qemu和virt
yum install qemu-kvm libvirt virt-install
```


#### 配置桥接网卡

```shell
nmcli con add type bridge con-name br0 ifname br0
# 创建桥接卡名称为br0

nmcli con add type bridge-slave con-name br0-port1 ifname eth0 master br0
# 将物理网卡eth0加入桥接卡br0


# 下面三条指令是为桥接卡配置手动IP，可以直接用nmtui完成操作
nmcli con modify br0 ipv4.addresses 192.168.0.2/24
nmcli con modify br0 ipv4.gateway 192.168.0.1
nmcli con modify br0 ipv4.method manual


nmcli con up br0
# 启动桥接卡
```

#### 创建虚拟机

```shell
qemu-img create -f qcow2 linux1.qcow2 40G

virt-install \
 --name=linux1 \
 --memory=4096 \
 --vcpus=2 \
 --disk path=linux1.qcow2,size=40 \
 --cdrom=/opt/Rocky-9.1-aarch64-dvd.iso \
 --network bridge=br0,model=virtio \
 --graphics vnc,listen=0.0.0.0,password=Key-1122 \
 --os-variant=rocky9 \
 --virt-type=kvm \
 --boot cdrom,hd
```

#### 其他virsh指令

```shell
#删除虚拟机

#先关闭虚拟机
#执行以下指令删除虚拟机linux1
virsh undefine --domain linux1 --remove-all-storage --nvram
```


#### 为linux8添加两块大小为5G的硬盘

```shell
#创建硬盘文件
qemu-img create -f qcow2 /opt/disk1.qcow2 5G
qemu-img create -f qcow2 /opt/disk2.qcow2 5G

#将硬盘附加到虚拟机中
virsh attach-disk linux8 /opt/disk1.qcow2 vdb --subdriver=qcow2 --persistent
virsh attach-disk linux8 /opt/disk2.qcow2 vdc --subdriver=qcow2 --persistent

##删除磁盘指令 
virsh detach-disk <vm-name> vdb --persistent
```

#### 快照配置

```shell
#为linux1创建名称为linux-snapshot的快照
virsh snapshot-create-as linux1 linux-snapshot

#克隆linux1到linux2
virt-clone --original linux1 --name linux2 --file /opt/linux2.qcow2
#解决在克隆时如果出现"The requested volume capacity will exceed...."
virt-clone --original linux1 --name linux2 --file /opt/linux2.qcow2 --check disk_size=off




#删除快照
#列出所有快照
virsh snapshot-list <domain>

#确定要删除的快照的名称或ID。
#使用以下命令删除快照
virsh snapshot-delete <domain> <snapshot>
#其中<domain>是虚拟机的名称或ID，<snapshot>是要删除的快照的名称或ID。

#删除所有快照
virsh snapshot-delete <domain> --all
```


#### 其他问题
- 如果出现运行virsh指令报错,直接重启系统即可


#### virsh虚拟机导出
```shell
#代码格式
virsh dumpxml vm-name > export-file.xml

#实例倒出
virsh dumpxml my_virtual_machine > /path/to/export-file.xml
#xml文件只会包含虚拟机信息，不会额外导出磁盘，磁盘需要格外复制或者移动
#导入虚拟机时需要修改磁盘路径
```

#### virsh虚拟机导入
```shell
#导入指令
virsh define export-file

#启动虚拟机
virsh start vm-name



```
```
