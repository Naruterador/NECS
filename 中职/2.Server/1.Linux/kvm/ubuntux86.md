## 问题:
- X86架构计算机操作系统安装与管理
  - PC1系统为ubuntu-desktop-amd64系统（已安装，语言为英文），登录用户为xiao，密码为Key-1122。启用root用户，密码为Key-1122。
  - 安装remmina，用该软件连接Server1上的虚拟机，并配置虚拟机上的相应服务。
  - 安装qemu和virtinst。
  - 安装windows8，系统为Windows Server 2022 Datacenter Desktop，网络模式为桥接模式，网卡、硬盘、显示驱动均为virtio，安装网卡、硬盘、显示驱动并加入到Windows AD中。
  - 安装windows9，系统为Windows Server 2022 Datacenter Desktop，网络模式为桥接模式，网卡、硬盘、显示驱动均为virtio，安装网卡、硬盘、显示驱动并加入到Windows AD中。在windows9中添加3块5GB的硬盘（硬盘驱动为virtio），初始化为GPT，配置为raid5。驱动器盘符为D。
  - 创建Windows Server 2022虚拟机，虚拟机信息如下：


    | 虚拟机名称 | vCPU | 内存   | 硬盘 | IPv4地址        | 完全合格域名       |
    |------------|------|--------|------|----------------|------------------|
    | windows8   | 2    | 4096MB | 40GB | 10.2.11.101/24 | windows8.skills.lan |
    | windows9   | 2    | 4096MB | 40GB | 10.2.11.102/24 | windows9.skills.lan |
---

## 解:
### 安装qemu和virtinst

```shell
#给/home/xiao目录添加一个执行权限，否则在会报错以下错误:
#WARNING  /home/xiao/Downloads/zh-cn_windows_server_2022_updated_oct_2022_x64_dvd_884ce1ea.iso may not be accessible by the hypervisor. You will need to grant the 'libvirt-qemu' user search permissions for the following directories: ['/home/xiao']

sudo chmod 755 /home/xiao
#或者
sudo chmod o+x /home/xiao


#将qemu和virtinst的安装包拷贝到主机，架设路径为/home/xiao/vir
#修改apt配置文件内容指向本地安装源,假设本地仓库目录为/home/xiao/vir:
sudo vim /etc/apt/sources.list
deb file:/home/xiao/vir ./

#更新安装源:
sudo apt-get update
#这里如不改安装源，会出现安装不动的情况，原因是因为source.list文件默认走网络安装

#使用以下指令安装(先进入包所在目录)
sudo apt-get install -f ./* 
```


### 配置网卡桥接用于连接

```shell
#打开配置文件
sudo vim /etc/netplan/01-netxxxx.yaml

network:
  version: 2
  renderer: NetworkManager
  ethernets:                #定义网卡名称
    eno1:                        
      dhcp4: no
  bridges:                 #创建桥接卡
   br0:                    #桥接卡名称br0
     dhcp4: no
     interfaces:
      - eno1
     addresses: [192.168.107.30/24]
     gateway4: 192.168.107.254
     nameservers:
           addresses: [172.16.1.1]


#netplan apply            #生效配置
```

### 创建虚拟机名称为windows8

```shell
qemu-img create -f qcow2 /opt/windows8.qcow2 40G             #建虚拟机磁盘

sudo virt-install \                                          #创建虚拟机
--name windows8 \
--memory 4096 \
--vcpus 2 \
--disk path=windows8.qcow2,size=40,bus=virtio,format=qcow2 \
--disk path=virtio-win-0.1.229.iso,device=cdrom \
--cdrom zh-cn_windows_server_2022_updated_oct_2022_x64_dvd_884ce1ea.iso \
--network bridge=br0,model=virtio \
--graphics vnc,listen=0.0.0.0 \
--video virtio \
--os-variant win2k22 \
--noautoconsole \
--boot cdrom,hd \
--cpu host \
```

### 其他virsh指令

```shell
#要列出所有虚拟机，可以使用以下命令：
sudo virsh list --all

#启动虚拟机
sudo virsh start <虚拟机名称>

#关闭虚拟机
sudo virsh shutdown <虚拟机名称>

#删除虚拟机
sudo virsh shutdown <虚拟机名称>     #先关闭虚拟机

virsh undefine <虚拟机名称>      #删除虚拟机定义

rm <虚拟机磁盘文件>             #删除虚拟机磁盘文件

#删除磁盘指令
#查看目前的磁盘信息
virsh domblklist windows8

删除磁盘(需要在虚拟机开机状态下运行指令)
virsh detach-disk centos7.9 /data/centos7/centos_data.qcow2
```

### ubuntu配置连接云平台1.0的imbc接口配置

```shell
#先登录https://192.168.100.10,点击控制台下载launch.jnlp

sudo apt -y install icedtea-netx
javaws launch.jnlp
```
