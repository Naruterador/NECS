## 例题:
- 配置 linux3 为 mariadb 服务器，创建数据库用户 xiao，在任意机器上对所有数据库有完全权限。创建数据库 userdb；在库中创建表 userinfo，表结构如下：
  
| 字段名      | 数据类型         | 主键  | 自增  |
| :------- | :----------- | :-- | :-- |
| id       | int          | 是   | 是   |
| name     | varchar(10)  | 否   | 否   |
| height   | float        | 否   | 否   |
| birthday | datetime     | 否   | 否   |
| sex      | varchar(5)   | 否   | 否   |
| password | varchar(200) | 否   | 否   |

- 在表中插入 2 条记录，分别为(1,user1,1.61,2000-07-01，M)，(2,user2，1.62,2000-07-02，F)，password 字段与 name 字段相同，password 字段用 md5 函数加密。
- 新建/var/mariadb/userinfo.txt 文件，文件内容如下，然后将文件内容导入到userinfo 表中，password 字段用 md5 函数加密。
  3,user3,1.63,2000-07-03,F,user3
  4,user4,1.64,2000-07-04,M,user4
  5,user5,1.65,2000-07-05,M,user5
  6,user6,1.66,2000-07-06,F,user6
  7,user7,1.67,2000-07-07,F,user7
  8,user8,1.68,2000-07-08,M,user8
  9,user9,1.69,2000-07-09,F,user9
- 将表 userinfo 中的记录导出，并存放到/var/mariadb/userinfo.sql，字段之间用','分隔。
- 为 root 用户创建计划任务（day 用数字表示），每周五凌晨 1:00 备份数据库 userdb（含创建数据库命令）到/var/mariadb/userdb.sql。（为便于测试，手动备份一次。）


## 解:
```shell
create user 'xiao'@'localhost' identified by 'Netw@rkCZ!@#';
grant all on *.* to 'xiao'@'localhost';
flush privileges

create table userinfo (id int not null auto_increment primary key,name varchar(10),height float,birthday datetime,sex varchar(5),password varchar(200));

insert into userinfo values(1,'user1',1.61,'2000-07-01','M',MD5('user1'));
insert into userinfo values(2,'user2',1.62,'2000-07-02','F',MD5('user2'));

alter table userinfo add height float after name;
update userinfo set height=1.61 where id=1;

vim userinfo.txt
3,user3,1.63,2000-07-03,F,user3
4,user4,1.64,2000-07-04,M,user4
5,user5,1.65,2000-07-05,M,user5
6,user6,1.66,2000-07-06,F,user6
7,user7,1.67,2000-07-07,F,user7
8,user8,1.68,2000-07-08,M,user8
9,user9,1.69,2000-07-09,F,user9

load data infile '/var/mariadb/userinfo.txt' into table userinfo columns terminated by ',' set password=md5(password);

chown mysql:mysql /var/mariadb #chmod 777 /var/mariadb
select * from userinfo INTO outfile '/var/mariadb/userinfo.sql' fields terminated by ',';

crontab -e
0 1 * * 5 mysqldump -u xiao -pNetw@rkCZ!@#  userdb > /var/mariadb/userdb.sql
```
# 有关cron任务计划配置文件解析
```shell
##😅说明:
#第一个星号表示分钟（0-59）
#第二个星号表示小时（0-23）
#第三个星号表示一个月中的某一天（1-31）
#第四个星号表示月份（1-12或者用缩写，如1表示一月，2表示二月）
#第五个星号表示星期几（0-7或者用缩写，0和7都表示星期日，1表示星期一，以此类推）
```
- 特殊字符解析:
![pics](../../Pics/p8.png)
