## 问题:
- 任务描述：请采用ansible，实现自动化运维。
- 在linux1上安装ansible，作为ansible的控制节点。linux9作为ansible的受控节点。
  - 在 Ansible 控制节点上创建一个名为 web_server.yml 的 Playbook 文件。
  - 在 Playbook 中定义一个名为 web_server 的组，包含远程服务器的 IP 地址。
  - 在 Playbook 中使用适当的模块，安装 Nginx 软件包。
  - 在 Playbook 中使用适当的模块，配置 Nginx 的主要设置：监听端口应为 80。
  - 默认站点应该是一个简单的静态 HTML 页面，内容为 "Welcome to my website!"。
  - 配置文件应放置在/etc/nginx/conf.d/default.conf。
  - 在 Playbook 中使用适当的模块，启动 Nginx 服务并设置自启动。
  - 在 Playbook 的结尾处添加一个任务，检查 Nginx 服务是否正在运行，并显示消息为”nginx gogo!”。

## 解:
- 修改/etc/ansible/ansible.cfg
```shell
[defaults]
ask_pass = true

[privilege_escalation]
become = true
become_method = sudo
become_user = root


#如果已经做了免密登录，这步就不用做了
```

- 修改/etc/ansible/hosts
```shell

[web_server]
192.168.108.103

```

- 编辑剧本文件web_server.yml
```yaml
- name: Nginx Server configure
  hosts: web_server

  tasks:
    - name: Install Nginx
      yum:
        name: nginx
        state: present

    - name: Configure Nginx
      template:
        src: nginx.conf.test
        dest: /etc/nginx/conf.d/default.conf

    - name: Start Nginx and enable auto-start
      service:
        name: nginx
        state: started
        enabled: true

#修改首页文件内容
- name: Update index.html
  hosts: web_server

  tasks:
    - name: Create index.html file
      copy:
        content: "Welcome to my website!"
        dest: /usr/share/nginx/html/index.html

#检查nginx是否启动
- name: Check nginx service
  hosts: web_server
  gather_facts: true        #gather_facts用于收集目标主机的信息。

  tasks:
    - name: Check nginx service status
      command: systemctl is-active nginx
      register: nginx_status
      changed_when: false
      failed_when: false

    - name: Display status message
      debug:
        msg: "nginx gogo"
      when: nginx_status.stdout == 'active'
```

```c
//配置文件nginx.conf.test需要额外创建

vim nginx.conf.test

server {
    listen 80 default_server;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    location / {
    }
}
```

## ansible部署 go编程环境
- 配置ansible支持ssh密码

```shell
vim /etc/ansible/ansible.cfg
[defaults]
ask_pass = true


[privilege_escalation]
become = true
become_method = sudo
become_user = root
become_flags='-i'

#become=True（必须），开启切换用户
#become_method 支持sudo 或者 su，如果使用su切换用户，become_flags需要改成 '-' 或 '-l'。
#become_user 填写需要切换的用户
#become_flags sudo或者su命令的选项。ansible命令行没有对应选项，必须要写入ansible.cfg配置文件。
```

- 配置ansible剧本
```shell
vim install_golang.yml

---
- name: copyfile
  hosts: test
  tasks:
    - name: copyfile
      copy:
        src: /opt/go1.20.6.linux-amd64.tar.gz
        dest: /opt/go1.20.6.linux-amd64.tar.gz
    - name: install the golang
      shell: cd /opt && tar xzf go1.20.6.linux-amd64.tar.gz && mv go /usr/local
    - name: mkdir gopath
      shell: cd /usr/local/ && mkdir gopath
    - name: set GO environment
      lineinfile: dest=/etc/profile regexp="^export GOROOT=" line="export GOROOT=/usr/local/go"
    - name: set GO environment
      lineinfile: dest=/etc/profile regexp="^export GOPATH=" line="export GOPATH=/usr/local/gopath"
    - name: set GO environment
      lineinfile: dest=/etc/profile  regexp="^PATH=\$PATH:\$GOPATH" line="export PATH=$PATH:$GOPATH/bin:$GOROOT/bin"
    - name: source profile
      shell: source /etc/profile

```

- 测试go环境是否部署成功

```shell
ansible -m shell -a "go version" test
```

#### 如果验证命令执行出现下面的错误信息，是ansible登录时的 环境变量 问题导致的

```shell
# ansible -m shell -a "go version" test
localhost | FAILED | rc=127 >>
/bin/sh: go: command not foundnon-zero return code    
```
- 一般 ssh 用户登录执行的是login shell，会加载/etc/profile和~/.bash_profile；
- ansible这类ssh远程执行是non-login shell，不会加载etc/profile和~/.bash_profile,而是回去加载/etc/bashrc和~/.bashrc，所以之前的脚本会出现找不到go命令错误，要让ansible的脚本可以找到go命令，需要将脚本修改成如下配置:
```
vim install_golang.yml

---
- name: copyfile
  hosts: test
  tasks:
    - name: copyfile
      copy:
        src: /opt/go1.20.6.linux-amd64.tar.gz
        dest: /opt/go1.20.6.linux-amd64.tar.gz
    - name: install the golang
      shell: cd /opt && tar xzf go1.20.6.linux-amd64.tar.gz && mv go /usr/local
    - name: mkdir gopath
      shell: cd /usr/local/ && mkdir gopath
    - name: set GO environment
      lineinfile: dest=/etc/bashrc regexp="^export GOROOT=" line="export GOROOT=/usr/local/go"
    - name: set GO environment
      lineinfile: dest=/etc/bashrc regexp="^export GOPATH=" line="export GOPATH=/usr/local/gopath"
    - name: set GO environment
      lineinfile: dest=/etc/bashrc  regexp="^PATH=\$PATH:\$GOPATH" line="export PATH=$PATH:$GOPATH/bin:$GOROOT/bin"
    - name: source profile
      shell: source /etc/bashrc
```

## 批量创建ssh-keygen私钥
```shell
ansible all -m command -a "ssh-keygen -q -t rsa -N '' -f /root/.ssh/id_rsa"

ansible all -m copy -a "src=/root/.ssh/authorized_keys dest=/root/.ssh/authorized_keys"
```

## 命令行安装
```shell
ansible all -i [你的主机或主机组], -m yum -a 'name=vim,git,tree state=present'
```
