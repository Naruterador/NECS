## 题目
- 在 linux9上编写/root/createfile. sh 的shell脚本，创建20个文件/root/shell/file00 至/root/shell/file19
每个文件的内容为：文件名+文件创建次数，如file00文件不存在，则file00文件的内容为 “file00,1”
如果file00文件存在，则次数+1，则file00文件的内容为“file00,2”，每运行一次都+1。用/root/createfile.sh 命令测试。

```shell
#!/bin/bash

# 创建目录
mkdir -p /root/shell

# 循环创建文件
for i in $(seq -w 00 19); do
  filepath="/root/shell/file$i"
  if [ ! -f "$filepath" ]; then
    # 文件不存在，创建文件并写入内容
    echo "file$i,1" > "$filepath"
  else
    # 文件存在，读取次数，增加次数并更新文件
    count=$(cut -d ',' -f2 "$filepath")
    new_count=$((count + 1))
    echo "file$i,$new_count" > "$filepath"
  fi
done
```