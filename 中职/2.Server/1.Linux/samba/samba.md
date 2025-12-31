## 问题:
- 在 linux3 上创建 user00-user19 等 20 个用户；user00 和 user01 添加到 manager 组，user02 和 user03 添加到 dev 组。把用户
user00-user03 添加到 samba 用户。
- 配置 linux3 为 samba 服务器,建立共享目录/srv/sharesmb，共享名与目录名相同。manager 组用户对 sharesmb 共享有读写权限，dev 组对 sharesmb 共享有只读权限；用户对自己新建的文件有完全权限，对其他用户的文件只有读权限，且不能删除别人的文件。在本机用 smbclient 命令测试。
- 在 linux4 修改/etc/fstab,使用用户 user00 实现自动挂载linux3 的 sharesmb 共享到/sharesmb。

## 解:
```shell
for i in {00..19};do useradd user$i;done
groupadd  manager
groupadd  dev
usermod -aG manager user00
usermod -aG manager user01
usermod -aG dev user02
usermod -aG dev user03
smbpasswd  -a user00
smbpasswd  -a user01
smbpasswd  -a user02
smbpasswd  -a user03

mkdir /srv/sharesmb
chmod  1777 /srv/sharesmb/


yum install samba* -y
vi /etc/samba/smb.conf

[global]
        workgroup = SKILLS.LAN
        security = user

        passdb backend = tdbsam

        printing = cups
        printcap name = cups
        load printers = yes
        cups options = raw



[sharesmb]
        path=/srv/sharesmb
        write list=@manager
        valid users=@manager,@dev

```

- 在Linux4上挂载
```shell
yum install samba* cifs* -y

mkdir /sharesmb

vi /etc/fstab 
//linux3.skills.lan/sharesmb    /sharesmb       cifs    defaults,username=user00,password=Key-1122 0 0
```
