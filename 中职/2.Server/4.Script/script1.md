#### 在linux4上编写Bash脚本/root/fileMonitor.sh：执行后在后台常驻运行；监控/root目录下的文件变化；一旦被监控的目录下的文件发生增加、删除、修改，脚本应检测到，并记录到日志文件/var/log/fileMonitor.log中 ；日志内容如：“2023-6-15 18:21:32 /root/testfile.txt changed (or added, deleted)

```shell
#!/bin/bash

# 指定监控的目录
monitored_dir="/root"

# 指定日志文件路径
log_file="/var/log/fileMonitor.log"

# 获取当前时间并格式化
get_current_time() {
    date +"%Y-%m-%d %H:%M:%S"
}

# 记录变化到日志文件
log_change() {
    local current_time=$(get_current_time)
    local change_type=$1
    local file=$2
    echo "$current_time $file $change_type" >> "$log_file"
}

# 存储初始文件列表及其对应的哈希值
declare -A initial_files

# 获取初始文件列表及其哈希值
while IFS= read -r file; do
    initial_files["$file"]=$(md5sum "$monitored_dir/$file" | awk '{print $1}')
done < <(find "$monitored_dir" -type f -printf "%P\n")

# 开始监控目录
while true; do
    current_files=$(find "$monitored_dir" -type f -printf "%P\n")

    # 检查是否有新文件添加或文件被修改
    for file in $current_files; do
        if [[ -v initial_files["$file"] ]]; then
            current_hash=$(md5sum "$monitored_dir/$file" | awk '{print $1}')
            if [[ "${initial_files["$file"]}" != "$current_hash" ]]; then
                log_change "changed" "$monitored_dir/$file"
                initial_files["$file"]=$current_hash
            fi
        else
            log_change "added" "$monitored_dir/$file"
            initial_files["$file"]=$(md5sum "$monitored_dir/$file" | awk '{print $1}')
        fi
    done

    # 检查是否有文件被删除
    for file in "${!initial_files[@]}"; do
        if ! grep -q "^$file$" <<< "$current_files"; then
            log_change "deleted" "$monitored_dir/$file"
            unset initial_files["$file"]
        fi
    done

    # 等待一段时间后重新扫描文件
    sleep 5
done
````
