8、创建和使用逻辑卷
创建一个名为/home/student/ansible/lv.yml 的playbook，它将在所有受管节点上运行以执行下列任务：
创建符合以下要求的逻辑卷：
逻辑卷创建在research卷组中
逻辑卷名称为data
逻辑卷大小为1500MiB
使用ext4文件系统格式化逻辑卷
如果无法创建请求的逻辑卷大小，应显示错误消息
Could not create logical volume of that size，并且应改为使用大小 800MiB。
如果卷组research 不存在 ，应显示错误消息
Volume group does not exist。
不要以任何方式挂载逻辑卷
前期环境  
首先执行lvm_pre.yml  
[student@workstation ansible]$ ansible-playbook lvm_pre.yml
答题：
```cpp

[student@workstation ansible]$ vim lv.yml

---
- name: create lvm
  hosts: all
  tasks:
    - name: create lv data
      block:
        - name: create lv 1500M
          lvol:
            lv: data
            vg: research
            size: 1500M
      rescue:
        - name: output fail message
          debug:
            msg: Could not create logical volume of that size
            
        - name: create lv 800M
          lvol:
            lv: data
            vg: research
            size: 800M
            
      always:
        - name: format lv
          filesystem:
            dev: /dev/research/data
            fstype: ext4
      when: "'research' in ansible_lvm.vgs"
      
    - name: search not exists
      debug:
        msg: Volume group does not exist
      when: "'research' not in ansible_lvm.vgs"

[student@workstation ansible]$ ansible-playbook lv.yml
```

创建和使用分区
创建名为partition.yml的playbook，对所有节点进行操作：
在vdb上创建一个主分区1500MiB
使用ext4文件系统进行格式化
将文件系统挂载到/newpart
如果分区大小不满足，产生报错信息 could not create partition os that size
则创建分区大小变成800MiB
如果磁盘不存在，产生报错信息：disk does not exist
```cpp
解答：
[student@workstation ansible]$ vim partition.yml
---
- name: create partition
  hosts: all
  tasks:
    - name: create part1
      block:
        - name: create part 1500
          parted:
            device: /dev/vdb
            number: 1
            part_type: primary
            part_start: 10MiB
            part_end: 1510MiB
            state: present
            
      rescue:
        - name: output fail message
          debug:
            msg: could not create partition os that size
            
        - name: create part 800
          parted:
            device: /dev/vdb
            number: 1
            part_type: primary
            part_start: 10MiB
            part_end: 800MiB
            state: present

      always:    
        - name: format part
          filesystem:
            dev: /dev/vdb1
            fstype: ext4

        - name: create mount point
          file:
            path: /newpart
            state: directory

        - name: mount
          mount:
            src: /dev/vdb1
            path: /newpart
            fstype: ext4
            state: mounted
      when: "ansible_devices.vdb is defined"
          
    - name: vdb not exist
      debug:
        msg: disk  does not exist
      when: "ansible_devices.vdb is not defined"
   
[student@workstation ansible]$ ansible-playbook partition.yml
由于练习环境原因，此playbook无法正常运行。

```



9、生成主机文件
将一个初始模板文件从http://content.example.com/hosts.j2下载到/home/student/ansible
完成该模板，以便用它生成以下文件：针对每个清单主机包含一行内容，其格式与 /etc/hosts 相同
创建名为 /home/student/ansible/hosts.yml 的playbook，它将使用此模板在 dev 主机组中的主机上生成文件 /etc/myhosts。
该 playbook 运行后，dev 主机组中主机上的文件/etc/myhosts 应针对每个受管主机包含一行内容：
127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4
::1 localhost localhost.localdomain localhost6 localhost6.localdomain6
172.24.1.6 servera.lab1.example.com servera
172.24.1.7 serverb.lab1.example.com serverb
172.24.1.8 serverc.lab1.example.com serverc
172.24.1.9 serverd.lab1.example.com serverd
172.24.1.10 bastion.lab1.example.com bastion
```cpp
解答：
[student@workstation ansible]$ wget http://content.example.com/hosts.j2
[student@workstation ansible]$ vim hosts.j2
127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4
::1 localhost localhost.localdomain localhost6 localhost6.localdomain6
{% for host in groups.all %}
{{ hostvars[host].ansible_enp1s0.ipv4.address }}  {{ hostvars[host].ansible_fqdn }}  {{ hostvars[host].ansible_hostname }}
{% endfor %}

[student@workstation ansible]$ vim hosts.yml

---
- name: get all facts
  hosts: all
- name: cp to myhosts
  hosts: dev
  tasks:
    - name: cp file
      template:
        src: /home/student/ansible/hosts.j2
        dest: /etc/myhosts


验证：
[root@servera ~]# cat /etc/myhosts 
127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4
::1 localhost localhost.localdomain localhost6 localhost6.localdomain6
172.25.250.10  servera.lab.example.com  servera
172.25.250.11  serverb.lab.example.com  serverb
172.25.250.254  bastion.lab.example.com  bastion
172.25.250.12  serverc.lab.example.com  serverc
172.25.250.13  serverd.lab.example.com  serverd

```

10、修改文件内容
按照下方所述，创建一个名为 /home/student/ansible/issue.yml 的 playbook：
该 playbook 将在所有清单主机上运行
该 playbook 会将 /etc/issue 的内容替换为下方所示的一行文本：
在 dev 主机组中的主机上，这行文本显示为：Development
在 test 主机组中的主机上，这行文本显示为：Test
在 prod 主机组中的主机上，这行文本显示为：Production
```cpp
解答：
[student@workstation ansible]$ vim issue.yml

---
- name: modify issue
  hosts: all
  tasks:
    - name: input to issue
      copy:
        content: |
          {% if 'dev' in group_names %}
          Development
          {% elif 'test' in group_names %}
          Test
          {% elif 'prod' in group_names %}
          Production
          {% endif %}
        dest: /etc/issue

[student@workstation ansible]$ ansible-playbook issue.yml 


验证：
[root@servera ~]# cat /etc/issue
Development

[root@serverb ~]# cat /etc/issue
Test

[root@serverc ~]# cat /etc/issue
Production

[root@serverd ~]# cat /etc/issue
Production

```

11、创建Web内容目录
按照下方所述，创建一个名为 /home/student/ansible/webcontent.yml 的 playbook：
该 playbook 在 dev 主机组中的受管节点上运行
创建符合下列要求的目录 /webdev：
所有者为 devops 组
具有常规权限：owner=read+write+execute，group=read+write+execute，other=read+execute
具有特殊权限: set group ID
用符号链接将 /var/www/html/webdev 链接到 /webdev
创建文件 /webdev/index.html，其中包含如下所示的单行文本：Development
在 dev 主机组中主机上浏览此目录（例如 http://servera.lab.example.com/webdev/ ）将生成以下输出：
Development
```cpp
[student@workstation ansible]$ vim webcontent.yml

---
- name: web station
  hosts: dev
  tasks:
    - name: install httpd firewalld
      yum:
        name: 
          - httpd
          - firewalld
        state: present

    - name: create group
      group: 
        name: devops
        state: present
        
    - name: create /webdev
      file:
        path: /webdev
        state: directory
        group: devops
        mode: 2775
        
    - name: cp
      copy:
        content: Development
        dest: /webdev/index.html
        
    - name: set selinux context
      sefcontext:
        target: /webdev(/.*)?
        setype: httpd_sys_content_t
        
    - name: shell
      shell:
        cmd: restorecon -Rv /webdev

    - name: create link to /var/www/html/webdev
      file:
        src: /webdev
        dest: /var/www/html/webdev
        state: link

    - name: restart httpd
      service:
        name: httpd
        state: restarted
        enabled: yes

    - name: restart firewalld
      service: 
        name: firewalld
        state: restarted
        enabled: yes

    - name: firewall for http
      firewalld:
        service: http
        state: enabled
        permanent: yes
        immediate: yes

[student@workstation ansible]$ ansible-playbook webcontent.yml 


验证：
[student@workstation ansible]$ curl http://servera.lab.example.com/webdev/
Development

```

12、生成硬件报告
创建一个名为 /home/student/ansible/hwreport.yml的 playbook，它将在所有受管节点上生成含有以下信息的输出文件 /root/hwreport.txt：

输出文件中的每一行含有一个 key=value 对。
您的 playbook 应当：
从 http://content.example.com/hwreport.empty 下载文件，并将它保存为/root/hwreport.txt
使用正确的值修改 /root/hwreport.txt
如果硬件项不存在，相关的值应设为NONE
```cpp
解答：
[student@workstation ansible]$ vim hwreport.yml
---
- name: get hwreport
  hosts: all
  tasks:
    - name: Create report file
      get_url:
        url: http://content.example.com/hwreport.empty
        dest: /root/hwreport.txt

    - name: get inventory_hostname
      replace:
        path: /root/hwreport.txt
        regexp: 'inventoryhostname'
        replace: "{{ inventory_hostname }}"

    - name: get mem 
      replace:
        path: /root/hwreport.txt
        regexp: 'memory_in_MB'
        replace: "{{ ansible_memtotal_mb }}"

    - name: get bios
      replace:
        path: /root/hwreport.txt
        regexp: 'BIOS_version'
        replace: "{{ ansible_bios_version }}"

    - name: get vda
      replace:
        path: /root/hwreport.txt
        regexp: 'disk_vda_size'
        replace: "{{ ansible_devices.vda.size if ansible_devices.vda is defined else 'NONE'}}"

    - name: get vdb
      replace:
        path: /root/hwreport.txt
        regexp: 'disk_vdb_size'
        replace: "{{ ansible_devices.vdb.size if ansible_devices.vdb is defined else 'NONE'}}"


[student@workstation ansible]$ ansible-playbook hwreport.yml

```

13、创建密码库
按照下方所述，创建一个 Ansible 库来存储用户密码：
库名称为 /home/student/ansible/locker.yml
库中含有两个变量，名称如下：
pw_developer，值为 Imadev
pw_manager，值为 Imamgr
用于加密和解密该库的密码为whenyouwishuponastar
密码存储在文件 /home/student/ansible/secret.txt中
```cpp
解答：
[student@workstation ansible]$ vim locker.yml
---
pw_developer: lmadev
pw_manager: lmamgr
[student@workstation ansible]$ echo whenyouwishuponastar > secret.txt
[student@workstation ansible]$ chmod 600 secret.txt
[student@workstation ansible]$ ansible-vault encrypt locker.yml --vault-id=/home/student/ansible/secret.txt 

```

14、创建用户账户
从 http://content.example.com/user_list.yml 下载要创建的用户的列表，并将它保存到 /home/student/ansible
在本次考试中使用在其他位置创建的密码库 /home/student/ansible/locker.yml，创建名为/home/student/ansible/users.yml 的playbook，从而按以下所述创建用户帐户：
职位描述为 developer 的用户应当：
在 dev 和 test 主机组中的受管节点上创建
从 pw_developer 变量分配密码,密码有效期为30天
是附加组 student 的成员
职位描述为 manager 的用户应当：
在 prod 主机组中的受管节点上创建
从 pw_manager 变量分配密码，密码有效期为30天
是附加组 opsmgr 的成员
密码应采用 SHA512 哈希格式。
您的 playbook 应能够在本次考试中使用在其他位置创建的库密码文件/home/student/ansible/secret.txt 正常运行
```cpp
解答：
[student@workstation ansible]$ wget http://content.example.com/user_list.yml
[student@workstation ansible]$ vim users.yml 
--- 
- name: create developer user 
  hosts: dev, test 
  vars_files: 
    - /home/student/ansible/locker.yml 
    - /home/student/ansible/user_list.yml 
  tasks: 
    - name: create group student 
      group: 
        name: student 
        state: present 

    - name: create user in developer 
      user: 
        name: "{{ item.name }}" 
        groups: student 
        password: "{{ pw_developer | password_hash('sha512') }}" 
        state: present
      loop: "{{ users }}" 
      when: item.job == "developer" 
    - name: chage
      shell: 
        cmd: chage -M 30 {{ item.name }}
      loop: "{{ users }}"
      when: item.job == "developer"
- name: create manager user 
  hosts: prod 
  vars_files: 
    - /home/student/ansible/locker.yml 
    - /home/student/ansible/user_list.yml 
  tasks: 
    - name: create group opsmgr 
      group: 
        name: opsmgr 
        state: present 

    - name: create user in manager 
      user: 
        name: "{{ item.name }}" 
        groups: opsmgr 
        password: "{{ pw_manager | password_hash('sha512') }}" 
        state: present
      loop: "{{ users }}" 
      when: item.job == "manager" 
    - name: chage1
      shell: 
        cmd: chage -M 30 {{ item.name }}
      loop: "{{ users }}"
      when: item.job == "manager"

[student@workstation ansible]$ ansible-playbook users.yml --vault-id secret.txt 

```

15、更新Ansible库的密钥
按照下方所述，更新现有 Ansible 库的密钥：
从 http://content.example.com/salaries.yml 下载 Ansible 库到 /home/student/ansible
当前的库密码为 AAAAAAAAA
新的库密码为 bbe2de98389b
库使用新密码保持加密状态
```cpp
解答：
[student@workstation ansible]$ wget http://172.25.250.250/ansible2.8/salaries.yml 
[student@workstation ansible]$ ansible-vault rekey salaries.yml
输入旧密码
输入新密码
确认新密码

```

#### 16、创建⼀个名为 /home/greg/ansible/cron.yml 的 playbook ，

配置 cron 作业，该作业每隔 2 分钟运⾏并执⾏以下命令：  
logger “EX294 in progress”，以⽤户 natasha 身份运⾏
```cpp
[student@workstation ansible]$ vim cron.yml
---
- name: create cron
  hosts: all
  tasks:
    - name: create  user
      user:
        name: natasha
        state: present

    - name: create cron for all
      cron:
        name: cy
        minute: '*/2'
        job: logger "EX294 in progress"
        user: natasha


[student@workstation ansible]$ ansible-playbook cron.yml

```