## 配置telnet

  

```shell

username admin privilege 15 password admin //创建用户

line vty 0 4

login local //进入line配置界面，设置模式为本地用户认证

enable password 7 123456 //为特权模式设置密文密码

```