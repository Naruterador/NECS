s## Minio安装
```shell
dnf install https://dl.minio.org.cn/server/minio/release/linux-amd64/minio-20250723155402.0.0-1.x86_64.rpm
```




```shell
export MINIO_ROOT_USER=admin
export MINIO_ROOT_PASSWORD=Key-1122

minio server \
  http://192.168.255.11/data/minio \
  http://192.168.255.12/data/minio \
  http://192.168.255.13/data/minio \
  http://192.168.255.14/data/minio \
  --console-address :9090 &
```



## 通过mc访问集群
### 安装mc
```shell
wget https://dl.minio.org.cn/client/mc/release/linux-amd64/mc -O /usr/local/bin/mc
chmod +x /usr/local/bin/mc
```

### 用mc连接集群
- 假设你集群第一个节点是：`http://192.168.255.11:9000`
- 则执行`mc alias set myminio http://192.168.255.11:9000 admin Key-1122`
    - 解释：
    - **myminio**：你给这个集群起的名字（随便取）
    - **http://192.168.255.11:9000**：访问 MinIO 集群任意一个节点的 9000 端口
    - **admin Key-1122**：你的 Root 用户名 + 密码
> ⚠ 注意：  
> MinIO 集群是“对等架构”，**你连接任何一个节点 = 连接整个集群**。

### 验证是否连接成功
```shell
#查看集群状态
mc admin info myminio

#查看节点健康
mc admin heal myminio

#查看所有bucket
mc ls myminio

#创建一个 bucket
mc mb myminio/testbucket

#上传文件
mc cp /etc/hosts myminio/testbucket
```


## 对象版本控制（Versioning）
- 同一个文件（对象）上传多次时，MinIO 不覆盖旧版本，而是保留所有历史版本。
```shell
#开启 Versioning
mc version enable myminio/mybucket

#关闭 Versioning
mc version suspend myminio/mybucket
```

- Versioning 开启后，MinIO 存储行为发生重大变化
- 上传同名文件 = 自动创建新版本,不会覆盖旧文件。
```shell
#查看文件的所有历史版本
mc ls --versions myminio/mybucket
```
- 删除文件 = 只加删除标记,不是真删,真实删除必须使用 version-id
```shell
mc rm myminio/mybucket/file.jpg --version-id "xxxx"
```
- 恢复某个历史版本
```shell
mc cp myminio/mybucket/file.jpg --version-id "xxxx" ./restore.jpg
```
