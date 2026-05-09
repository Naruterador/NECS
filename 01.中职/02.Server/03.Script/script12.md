## 题目
任务描述：请采用shell脚本,实现nginx运维监视。

(1) 在linux2上创建服务监控脚本：/root/nginxchk.sh；

(2) 编写脚本监控https://linux2.contoso.net网站运行情况；

(3) 脚本可以在后台持续运行，如果访问正常则返回“访问正常！”；每隔5S检查一次网站的运行状态，如果发现异常尝试5次；如果确定网站无法访问，则返回用户“网站目前正处于维护状态，请稍后再试”的页面。

## 解:
```shell
#!/bin/bash

URL="https://linux2.contoso.net"

while true
do
    curl -k -s --connect-timeout 3 "$URL" > /dev/null

    if [ $? -eq 0 ]; then
        echo "访问正常！"
    else
        echo "访问异常，开始重试..."

        n=0
        while [ $n -lt 5 ]
        do
            sleep 5
            curl -k -s --connect-timeout 3 "$URL" > /dev/null

            if [ $? -eq 0 ]; then
                echo "访问正常！"
                break
            fi

            n=$((n+1))
        done

        if [ $n -eq 5 ]; then
            echo "网站目前正处于维护状态，请稍后再试"
        fi
    fi

    sleep 5
done
```