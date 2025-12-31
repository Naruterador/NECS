## 问题:
- 配置 linux2 为 kdc 服务器，负责 linux3 和 linux4 的验证。
- 在 linux3 上，创建用户，用户名为 xiao，uid=222，gid=222，家目录为/home/xiaodir。 
- 配置 linux3 为 nfs 服务器，目录/srv/sharenfs 的共享要求为：linux 服务器所在网络用户有读写权限，所有用户映射为 xiao，
- kdc 加密方式为 krb5p。 
- 配置 linux4 为 nfs 客户端，利用 autofs 按需挂载 linux3上的/srv/sharenfs 到/sharenfs 目录，挂载成功后在该目录创建 test目录。

## 解:
```shell
#安装nfs服务
yum install nfs-utils(适用于rockylinux9)

useradd -u 222 -d /home/xiaodir xiao
groupmod  -g 222 xiao

mkdir /srv/sharenfs
chown  xiao:xiao /srv/sharenfs/

vi /etc/exports
/srv/sharenfs   10.6.220.0/24(rw,anonuid=222,anongid=222,sec=krb5p)

systemctl restart nfs-server
showmount -e


#no_all_squash：
#当设置了此选项时，表示连接到NFS服务器的远程客户端将保留其原始用户和组身份（UID和GID）在访问NFS共享上的文件和目录时。换句话说，即使连接到NFS共享的客户端在服务器上没有相应的用户帐户，服务器也不会"压缩"或更改文件的所有权。
#使用 no_all_squash 时，从NFS客户端连接的用户可以具有与在本地系统上定义其用户帐户时相同的访问级别和权限。此选项通常用于管理员希望在不同系统之间保持一致的用户权限时。

#all_squash：
#另一方面，启用了 all_squash 选项，意味着所有对NFS共享的远程访问都会映射到NFS服务器上的单个匿名用户。这个用户通常具有非常有限的权限。
#使用 all_squash 时，无论远程客户端的用户拥有何种权限，在NFS服务器上所有的访问都会被映射为匿名用户的权限。这有助于确保对共享资源的访问受到严格的限制。


```

- 在Linux4上配置auto自动挂载
```shell

yum install autofs* -y

systemctl enable autofs
systemctl enable nfs-server

vi /etc/auto.master
# Sample auto.master file
# This is a 'master' automounter map and it has the following format:
# mount-point [map-type[,format]:]map [options]
# For details of the format look at auto.master(5).
#
/-       /etc/auto.nfs
#
# NOTE: mounts done from a hosts map will be mounted with the
#       "nosuid" and "nodev" options unless the "suid" and "dev"
#       options are explicitly given.
#
/net    -hosts
#
# Include /etc/auto.master.d/*.autofs
# To add an extra map using this mechanism you will need to add
# two configuration items - one /etc/auto.master.d/extra.autofs file
# (using the same line format as the auto.master file)
# and a separate mount map (e.g. /etc/auto.extra or an auto.extra NIS map)
# that is referred to by the extra.autofs file.
#
+dir:/etc/auto.master.d
#
# If you have fedfs set up and the related binaries, either
# built as part of autofs or installed from another package,
# uncomment this line to use the fedfs program map to access
# your fedfs mounts.
#/nfs4  /usr/sbin/fedfs-map-nfs4 nobind
#
# Include central master map if it can be found using
# nsswitch sources.
#
# Note that if there are entries for /net or /misc (as
# above) in the included master map any keys that are the
# same will not be seen as the first read key seen takes
# precedence.
#
+auto.master

vi /etc/auto.nfs
/sharenfs       -fstype=nfs     linux3.skills.lan:/srv/sharenfs

```

## 有关autofs配置文件的解释
- 在 auto.master 中，/- 用于指定直接映射模式。这与间接映射模式有所不同。让我们分别解释这两种模式：
  - 间接映射（Indirect Mapping）
    - 在间接映射中，你定义了一个基础挂载点，然后所有的子挂载点都在这个基础挂载点下面。例如，如果你有一个间接映射 /mnt /etc/auto.misc，那么在 auto.misc 文件中定义的所有挂载点都会在 /mnt 目录下。如果 auto.misc 中有一行定义了一个名为 share 的挂载点，实际上你会访问 /mnt/share 来触发这个挂载。
  - 直接映射（Direct Mapping）
    - 直接映射使用 / 前缀（在 auto.master 文件中表示为 /-），允许你直接在文件系统的任何位置定义挂载点。这意味着，与间接映射不同，你不受限于一个共同的基础挂载点。在直接映射中，每一个挂载点都是完全独立的，并且在映射文件（如 auto.nfs）中直接指定。

```shell

systemctl start autofs

cd /sharenfs/
```
