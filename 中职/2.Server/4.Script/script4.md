## 题目
- 在rocky linux上编写模仿日志功能的 shell 脚本 /root/createlogs.sh，在/root/logs 文件夹内创建20个文件，分别是"/root/logs/file00-当天日期.log” 至"/root/logs/file19-当天日期.log” 如在2024年3月9日创建的文件 /root/logs/file00-20240309.log 到 /root/logs/file19-20240309.log。文件内容为：“主文件名，次数”，上文日期值需脚本从系统获取，如2024年3月9日当天第一次运行脚本时，则file00-20240309.log文件的内容为“file00-20240309，1”。逗号后面的数字表示运行次数，当天时段内每运行一次，相应文件中在后面增加一行，且次数在上次最后一行的次数基础上+1。以上双引号皆为了表述清晰，不属于任何文件名或文件内容。用/root/createlogs.sh 命令测试。

```shell
#!/bin/bash

# 设置logs目录的路径
LOGS_DIR="/root/logs"
# 获取当前日期
CURRENT_DATE=$(date +%Y%m%d)

# 检查logs目录是否存在，如果不存在则创建
if [ ! -d "$LOGS_DIR" ]; then
  mkdir -p "$LOGS_DIR"
fi

# 循环创建20个log文件
for i in $(seq -w 0 19); do
  FILE_NAME="file${i}-${CURRENT_DATE}.log"
  FILE_PATH="${LOGS_DIR}/${FILE_NAME}"

  # 检查文件是否存在
  if [ -f "$FILE_PATH" ]; then
    # 获取文件中最后一次记录的次数，并加1
    LAST_COUNT=$(tail -n 1 "$FILE_PATH" | cut -d ',' -f 2 | tr -d ' ')
    NEXT_COUNT=$((LAST_COUNT + 1))
  else
    NEXT_COUNT=1
  fi

  # 向文件追加新的记录
  echo "${FILE_NAME},${NEXT_COUNT}" >> "$FILE_PATH"
done
```