### create_repo
- createrepo 是一个 Linux 下用于创建 RPM 软件包仓库的命令，通常用于基于 RPM 包管理的 Linux 发行版（如 CentOS、RHEL、Fedora 等）。它的作用是扫描指定目录中的 RPM 包文件，生成描述文件（repodata），供 yum 或 dnf 等包管理工具使用，以便用户可以方便地安装、更新或移除软件包。
```shell
#安装createrepo
yum install createrepo -y

#创建仓库
createrepo -v /path/to/repo
```

### 查询并列出所有可用 YUM 软件仓库的命令
```shell
yum repolist

yum repolist all
```

### yum只下载不安装rpm包
```shell
yum install --downloadonly --downloaddir=/path/to/download package_name
```