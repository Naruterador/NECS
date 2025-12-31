# 一、**安装虚拟主机**
|         |                 |
| ------- | --------------- |
| 主机名     | IP地址            |
| control | 10.50.24.101/24 |
| node1   | 10.50.24.102/24 |
| node2   | 10.50.24.103/24 |
| node3   | 10.50.24.104/24 |
| node4   | 10.50.24.105/24 |
| node5   | 10.50.24.106/24 |
| source  | 10.50.24.108/24 |
1.其中control为主控节点，node1、node2、node3、node4、node5为受控节点
2.source主机为资源节点，为受控节点提供yum安装源，并在source主机上安装httpd服务，并将资源文件resource放到网站根目录下

# 一、**配置要求**

### 1.安装和配置 Ansible
- 按照下⽅所述，在控制节点 control上安装和配置 Ansible
    - 安装所需的软件包
    - 创建名为 /home/greg/ansible/inventory 的静态清单⽂件，以满⾜以下要求：
        - node1 是 dev 主机组的成员
        - node2 是 test 主机组的成员
        - node3 和 node4 是 prod 主机组的成员
        - node5 是 balancers 主机组的成员
        - prod 组是 webservers 主机组的成员
- 创建名为 /home/greg/ansible/ansible.cfg 的配置⽂件，以满⾜以下要求：
    - 主机清单⽂件为 /home/greg/ansible/inventory
    - playbook 中使⽤的⻆⾊的位置包括 /home/greg/ansible/roles
    - ⾃定义的collection⽬录在 /home/greg/ansible/mycollection
#### 解答:
1.在control节点上安装ansible
  `yum install ansible-*`
2.修改`ansible`默人配置文件路径从`/etc/ansible/ansible.cfg`移动到`/home/greg/ansible/ansible.cfg`
```cpp
#将现有的 `ansible.cfg` 文件移动到 `/home/greg/ansible/` 目录
mv /etc/ansible/ansible.cfg /home/greg/ansible/ansible.cfg

#让 Ansible 识别新路径
#设置环境变量
export ANSIBLE_CONFIG=/home/greg/ansible/ansible.cfg

#要验证 Ansible 正在使用新的配置文件，可以运行以下命令：
ansible --version
```

3.修改`ansible`配置文件`/home/greg/ansible/ansible.cfg`,修改主机清单文件路径、角色清单文件路径和collection清单路径
```cpp
[defaults]
inventory = /home/greg/ansible/inventory              #修改主机清单文件路径
ask_pass = true                                       #如果没有做ssh免密登陆需要添加此参数
roles_path = /home/greg/ansible/roles                 #修改角色清单文件路径
collections_paths = /home/greg/ansible/mycollection   #修改collection清单路径

[privilege_escalation] #定义权限提升相关的配置
become = true
# 这个参数启用了权限提升
# 设置为 true 时，Ansible 在执行任务时会切换到指定的用户（通常是 root），来执行需要更高权限的操作
# 如果没有这个设置，Ansible 默认会使用远程主机上的连接用户（如 ansible 或 ubuntu 用户）来执行任务，而不会尝试提升权限

become_method = sudo
# 这个参数指定了提升权限时使用的方式。
# sudo 是一种常见的权限提升工具，它允许普通用户临时获得超级用户（root）权限来执行任务
# 其他常见的权限提升方法包括 su、pbrun、pfexec 等，但 sudo 是最常见的选择

become_user = root
# 这个参数指定了要切换的用户。在这里，Ansible 将通过 sudo 切换到 root 用户执行任务
# root 是 Linux/Unix 系统中的超级用户，拥有执行所有系统操作的权限
# 如果你想提升权限为其他用户（比如某个特定的服务账户），可以将 become_user 改为那个用户的名字
```
### 2.配置系统并使用默认存储库
- 作为系统管理员，您需要在受管节点上安装软件。
- 请按照正⽂所述，创建⼀个名为/home/greg/ansible/yum_repo.yml ，在各个受管节点上安装 yum 存储库
    - 存储库1：
        - 存储库的名称为 test_BASE
        - 描述为 test base software
        - 基础 URL 为 http://10.50.24.107/cdrom/BaseOS
        - GPG 签名检查为 启用状态
        - GPG 密钥 URL 为 http://10.50.24.107/cdrom/RPM-GPG-KEY-Rocky-9
        - 存储库为 启用状态
    - 存储库2：
        - 存储库的名称为 test_STREAM
        - 描述为 test base software
        - 基础 URL 为 http://10.50.24.107/cdrom/AppStream
        - GPG 签名检查为 启⽤状态
        - GPG 密钥 URL 为 http://10.50.24.107/cdrom/RPM-GPG-KEY-Rocky-9
        - 存储库为 启⽤状

#### 解答：
1.编写剧本`/home/greg/ansible/yum_repo.yml`
```yml
---
- name: Configure YUM repositories on managed nodes
  hosts: all  # 你可以指定具体的主机组
  become: yes

  tasks:
    - name: Configure test_BASE repository
      yum_repository:
        name: test_BASE
        description: "test base software"
        baseurl: "http://192.168.108.208/cdrom/BaseOS"
        gpgcheck: yes
        gpgkey: "http://192.168.108.208/RPM-GPG-KEY-Rocky-9"
        enabled: yes

    - name: Configure test_STREAM repository
      yum_repository:
        name: test_STREAM
        description: "test base software"
        baseurl: "http://192.168.108.208/cdrom/AppStream"
        gpgcheck: yes
        gpgkey: "http://192.168.108.208/RPM-GPG-KEY-Rocky-9"
        enabled: yes
```
2.执行剧本
`ansible-playbook /home/greg/ansible/yum_repo.yml`
### 3.安装软件包
- 创建⼀个名为 /home/greg/ansible/packages.yml 的 playbook:
    - 将 php 和 mariadb 软件包安装到 dev 、 test 和 prod 主机组中的主机上
    - 将 RPM Development Tools 软件包组安装到 dev 主机组中的主机上
    - 将 dev 主机组中主机上的 所有软件包更新为最新版本
#### 解答：
1.编写剧本`/home/greg/ansible/packages.yml`

```yml
---
- name: Install php and mariadb on dev, test, and prod groups
  hosts: dev:test:prod
  become: yes

  tasks:
    - name: Install php and mariadb packages
      package:
        name:
          - php*
          - mariadb*
        state: present

- name: Install RPM Development Tools and update packages on dev group
  hosts: dev
  become: yes

  tasks:
    - name: Install RPM Development Tools package group
      yum:
        name: "@Development Tools"
        state: present

    - name: Update all packages to the latest version
      yum:
        name: '*'
        state: latest
```
2.执行剧本
`ansible-playbook /home/greg/ansible/packages.yml`
### 4.使用 rhel 系统角色
- 安装 RHEL 系统⻆⾊软件包，并创建符合以下条件的 playbook /home/greg/ansible/selinux.yml:
   - 在所有受管节点上运⾏
   - 使⽤ selinux ⻆⾊
   - 配置该⻆⾊，配置被管理节点的 selinux 为 permissive
#### 解答:
1.安装rhel-system角色组件
  `yum install rhel-system-roles`
2.复制selinux角色模块到本题指定角色模块目录
  `cp -r /usr/share/ansible/roles/rhel-system-roles.selinux/* roles `
3.编写`/home/greg/ansible/selinux.yml`剧本
```yml
---
- name: Configure SELinux to permissive on all managed nodes
  hosts: all
  become: yes

  roles:
    - rhel-system-roles.selinux

  vars:
    selinux_state: permissive
```
4.执行剧本
`ansible-playbook selinux.yml`

### 5.配置conllection
- 将下面3个文件放到 192.168.108.208 web根目录服务器下的resource目录下
    -  redhat-insights-1.0.7.tar.gz
    -  community-general-5.5.0.tar.gz
    -  redhat-rhel_system_roles-1.19.3.tar.gz
    -  访问地址为http://192.168.108.208/resource
    -  将上面3个源码文件安装在 /home/greg/ansible/mycollection 目录中
#### 解答:
- 在控制节点上创建 `requirements.yml`
- `vim /home/greg/ansible/requirements.yml`
```yml
---
collections:
- name: http://192.168.108.208/resource/redhat-insights-1.0.7.tar.gz
- name: http://192.168.108.208/materials/community-general-5.5.0.tar.gz
- name: http://192.168.108.208/redhat-rhel_system_roles-1.19.3.tar.gz
```
- 用 `ansible-galaxy` 命令来安装 Ansible collections
- `ansible-galaxy collection install -r requirements.yml -p /home/greg/ansible/mycollection`
- 指令解释:
    - `ansible-galaxy`: 这是 Ansible 的一个命令行工具，用于管理 Ansible roles 和 collections。
    - `collection install`: 这个子命令告诉 ansible-galaxy 我们要安装 collections。
    - `-r requirements.yml`:
        - `-r` 是 `--requirements-file` 的简写
        - 这个选项指定了一个 YAML 文件，其中列出了要安装的 collections
        - `requirements.yml` 是这个文件的名称
    - `-p /home/greg/ansible/mycollection`:
        - `-p` 是 `--collections-path` 的简写
        - 这个选项指定了安装 collections 的目标路径
        - 在这个例子中，collections 将被安装到 `/home/greg/ansible/mycollection` 目录
- 这个命令的作用是：
    - 读取 `requirements.yml` 文件中列出的 collections
    - 安装这些 collections 到 `/home/greg/ansible/mycollection` 目录中
- 验证安装:
    - `ansible-galaxy collection list`
    - 会显示已安装的collections

6.使用 Ansible Galaxy 安装角色
- 使⽤ Ansible Galaxy 和要求⽂件 /home/greg/ansible/roles/requirements.yml 。从以下 URL 下载角色并安装到 /home/greg/ansible/roles ：
    - http://192.168.108.208/resource/haproxy.tar.gz 此⻆⾊的名称应当为 balancer
    - http://192.168.108.208/resource/phpinfo.tar.gz 此⻆⾊的名称应当为 phpinfo
- 首先，创建 `requirements.yml` 文件
- `vi /home/greg/ansible/roles/requirements.yml`
```shell
- src: http://192.168.108.208/resource/haproxy.tar.gz
  name: balancer

- src: http://192.168.108.208/resource/phpinfo.tar.gz
  name: phpinfo
```
- 使用 `ansible-galaxy` 命令安装这些角色
- `ansible-galaxy install -r /home/greg/ansible/roles/requirements.yml -p /home/greg/ansible/roles`
- `-p /home/greg/ansible/roles` 本参数就算不指定也不会安装到`/home/greg/ansible/roles`中
- 查看已安装的角色列表
    - `ansible-galaxy list -p /home/greg/ansible/roles`

### 7.创建和使用角色
- 根据下列要求，在 `/home/greg/ansible/roles` 中创建名为 `apache` 的⻆⾊：
    - 安装httpd 软件包，并配置为在系统启动时启动
    - 启动防火墙，并配置为在系统启动时启动
- 创建模板规则文件index.html.j2 ，内容如下/var/www/html/index.html:
    - Welcome to HOSTNAME on IPADDRESS
    - 其中，HOSTNAME 是受管节点的完全限定域名 ， IPADDRESS 则是受管节点的 IP 地址。
- 创建⼀个名为 /home/greg/ansible/apache.yml 的 playbook：
    - 该 play 在 webservers 主机组中的主机上运⾏并将使⽤ apache ⻆⾊