## 题目
- 在 Linux9上编写/root/checkurl.sh 的shell脚本，用于测试URL. 链接的可达性
- 使用 wget 以安静模式执行，使用蜘蛛模式检查指定的URL（http://cacti.xmrth.net/cacti/）是否有效，并在 2 秒后超时
- 不实际下载文件，而是将输出重定向到/dev/null，如果网站正常，显示 URL + “访问正常！”，2秒超时显示URL +“无法访问！”
- 如果连续超时3次后显示URL +“网站维护中，稍后再试”
- 整个检测程序运行5次后结束，并提示：“本次检测结束，结束时间：XXXX年XX月XX日XX时XX分XX秒”，XX为系统真实时间。

## 解
- wget版
```shell
#!/bin/bash

# 指定需要检测的URL
URL="http://cacti.xmrth.com/cacti"

# 检测次数和超时次数初始化
MAX_CHECKS=5
TIMEOUTS=0

# 开始检测
for (( i=1; i<=MAX_CHECKS; i++ ))
do
  # 使用wget检测URL
  if wget --spider --timeout=2 -q $URL 2>/dev/null; then
    echo "$URL 访问正常！"
    TIMEOUTS=0 # 重置超时次数
  else
    echo "$URL 无法访问！"
    let TIMEOUTS++
    if [ $TIMEOUTS -eq 3 ]; then
      echo "$URL 网站维护中，稍后再试"
      break
    fi
  fi
  sleep 1 # 等待1秒再进行下一次检测
done

# 显示结束时间
echo "本次检测结束，结束时间：$(date '+%Y年%m月%d日%H时%M分%S秒')"

```

- curl指令版
```shell
#!/bin/bash

# 指定需要检测的URL
URL="http://cacti.xmrth.com/cacti"

# 检测次数和超时次数初始化
MAX_CHECKS=5
TIMEOUTS=0

# 开始检测
for (( i=1; i<=MAX_CHECKS; i++ ))
do
  # 使用curl检测URL
  if curl --head --silent --max-time 2 --output /dev/null $URL; then
    echo "$URL 访问正常！"
    TIMEOUTS=0 # 重置超时次数
  else
    echo "$URL 无法访问！"
    let TIMEOUTS++
    if [ $TIMEOUTS -eq 3 ]; then
      echo "$URL 网站维护中，稍后再试"
      break
    fi
  fi
  sleep 1 # 等待1秒再进行下一次检测
done

# 显示结束时间
echo "本次检测结束，结束时间：$(date '+%Y年%m月%d日%H时%M分%S秒')"
```
