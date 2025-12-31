## 题目
- 在 linux上编写/root/checkurl.sh 的 shell脚本,用于测试网站链接的可达性
- 可以使用 curL、wget、rsync、ping 等工具）检查指定的 URL
- 比如：http://www.nintendo. us 是否有效，
- 如果网站正常，显示“访问正常！”，超时 2秒显示 “无法访问！”
- 如果连续超时 3次后显示“网站维护中，稍后再试..”，
- 整个检测程序运行 5 次后结束，并提示：“本次检测结束！”

## 解:
```shell
#!/bin/bash

# 目标URL
url="http://www.nintendo.us"

# 记录连续失败次数
fail_count=0

# 总尝试次数
total_tries=5

# 循环尝试
for (( i=1; i<=total_tries; i++ )); do
    # 使用curl检查网站是否可达，超时时间设置为2秒
    if curl --connect-timeout 2 -Is $url | grep -q '200 OK'; then
        echo "访问正常！"
        fail_count=0 # 重置连续失败次数
    else
        echo "无法访问！"
        ((fail_count++))
        
        # 检查是否连续失败3次
        if [ $fail_count -ge 3 ]; then
            echo "网站维护中，稍后再试.."
            fail_count=0
        fi
    fi
done

echo "本次检测结束！"



```