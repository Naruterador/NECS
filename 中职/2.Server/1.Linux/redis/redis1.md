## 问题1:
- 在 Redis 中创建一个名为 "tasks" 的列表。向列表中添加以下任务（按添加顺序）：
  - "Task 1: Complete project proposal"
  - "Task 2: Review project requirements"
  - "Task 3: Implement login functionality"
  - "Task 4: Write unit tests"
  - "Task 5: Deploy to production"

## 解:
```shell
#启动 Redis 客户端。可以在终端或命令提示符中键入以下命令：
redis-cli


#使用 LPUSH 命令向列表中添加任务。根据指定的顺序，将任务逐个添加到列表中。执行以下命令：
LPUSH tasks "Task 5: Deploy to production"
LPUSH tasks "Task 4: Write unit tests"
LPUSH tasks "Task 3: Implement login functionality"
LPUSH tasks "Task 2: Review project requirements"
LPUSH tasks "Task 1: Complete project proposal"

#验证任务是否成功添加。可以使用 LRANGE 命令查看列表中的所有元素。执行以下命令：
LRANGE tasks 0 -1

```

##问题2:
- 在 Redis 中创建一个名为 "scores" 的有序集合。向有序集合中添加以下学生成绩信息：
  - 学生姓名："Alice"，成绩：85
  - 学生姓名："Bob"，成绩：92
  - 学生姓名："Charlie"，成绩：78
  - 学生姓名："David"，成绩：95
  - 学生姓名："Eva"，成绩：88

##解：
```shell
#启动 Redis 客户端。可以在终端或命令提示符中键入以下命令：
redis-cli

#使用 ZADD 命令向有序集合中添加学生成绩信息。执行以下命令：
ZADD scores 85 "Alice"
ZADD scores 92 "Bob"
ZADD scores 78 "Charlie"
ZADD scores 95 "David"
ZADD scores 88 "Eva"

#验证学生成绩信息是否成功添加。可以使用 ZRANGE 命令获取有序集合中的所有成员及其分数。执行以下命令：
ZRANGE scores 0 -1 WITHSCORES


```
