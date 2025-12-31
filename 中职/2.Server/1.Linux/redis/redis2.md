## 题目

- 有数据表userinfo如下表，请使用HASH数据类型，key值如userinfo:id (userinfo:1001、userinfo:1002)，将上表数据存入7004节点，password字段值转换为MD5的值。

| Id   | name   | birthday   | city | Phone       | password |
|------|--------|------------|------|-------------|----------|
| 1001 | user01 | 1997-7-1   | BJ   | 13815012345 | user01   |
| 1002 | user02 | 1998-8-2   | GZ   | 13921054321 | user02   |

## 解：
- 计算密码的md5值
```shell
echo -n 'user01' | md5sum --tag
```

- 插入参数
```shell
hmset userinfo:1001 name user01 birthday 1997-7-1 city BJ Phone 13815012345 password 密码的md5的值
hmset userinfo:1002 name user02 birthday 1998-8-2 city GZ Phone 13921054321 password 密码的md5的值
```

- 查看插入哈希值
```shell
hgetall userinfo:1001

hget userinfo:1001 name
hget userinfo:1001 birthday

```