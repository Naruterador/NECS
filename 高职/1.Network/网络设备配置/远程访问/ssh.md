## ssh配置

  

```shell

enable service ssh-server //全局开启ssh服务

username admin privilege 15 password 987321Aa //配置本地用户tel

line vty 0 4

login local //设置line为本地用户验证

enable secret Admin123! //设置密文enable密码