## Mariadb Replication function
### Master端配置
#首先初始化数据库
```shell
systemctl start mariadb

mysql_secure_installation
```


```shell
/etc/my.cnf.d/mariadb-server.cnf
log-bin=in
binlog-format=row
binlog-do-db=skills
log-basename=skills-master1
server_id=1000
expire_logs_days=30
max_binlog_size=200M

mysql -uroot -p

stop slave;
create user 'repl'@'172.16.81.204' identified by '2wsx';

grant replication client on *.* to 'repl'@'172.16.81.204' identified by '2wsx';
grant replication salve on *.* to 'repl'@'172.16.81.204' identified by '2wsx';

flush privileges;

MariaDB [(none)]> show master status;
+---------------------------+----------+--------------+------------------+
| File                      | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+---------------------------+----------+--------------+------------------+
| skills-master1-bin.000002 |     1491 | skills       |                  |
+---------------------------+----------+--------------+------------------+
                                        #本题中只同步skills数据库


mysqldump --databases skills --user=root --password > /var/mariadb/skills.sql
mysql -u root -p < skills.sql
#这步操作如果是先做同步再做数据库就可以不用做
```

### Slave端配置
#首先初始化数据库
```shell
systemctl start mariadb

mysql_secure_installation
```

```shell
/etc/my.cnf.d/mariadb-server.cnf
log-bin=in
binlog-format=row
binlog-do-db=skills
log-basename=skills-master1
server_id=1001
expire_logs_days=30
max_binlog_size=200M

mysql -u root -p
stop slave;

change master to master_host='172.16.81.203',master_port=3306,master_user='repl',master_password='2wsx',master_log_file='skills-master1-bin.000002',master_log_pos=1014;
#master_log_file参数，需要在Master端使用show master status查看具体的名称，否则将无法同步
#master_log_pos参数，需要在Master端使用show master status查看具体的名称，否则将无法同步

start slave;

show slave status;
```

### 在master端修向skills库中的userinfo表插入新内容，查看Slave端是否有改变。