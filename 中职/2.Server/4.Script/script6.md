## 题目
- Mariadb Backup Script
  - 脚本文件：/shells/mysqlbk.sh；
  - 备份数据到/root/mysqlbackup 目录；
  - 备份脚本每隔 30 分钟实现自动备份；导出的文件名为 all-databases-20210213102333,其中20210213102333 为运行备份脚本的当前时间，精确到秒。

```shell
#!/bin/bash

# 设置 MySQL 数据库的用户名和密码
USER="root"
PASSWORD="Key-1122"

# 设置备份目录
BACKUP_DIR="/root/mysqlbackup"

while true; do
  # 创建备份目录，如果它不存在的话
  mkdir -p $BACKUP_DIR

  # 获取当前日期和时间
  DATETIME=$(date +"%Y%m%d%H%M%S")

  # 设置备份文件的名称
  BACKUP_FILE_NAME="all-databases-$DATETIME.sql"

  # 执行备份
  mysqldump -u $USER -p$PASSWORD --all-databases > $BACKUP_DIR/$BACKUP_FILE_NAME

  # 打印完成的消息
  echo "Backup was created successfully: $BACKUP_DIR/$BACKUP_FILE_NAME"

  # 等待1800秒（30分钟）
  sleep 1800
done
```
