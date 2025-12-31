## 配置rldp防环检测

  

```shell

  

S6(config)#rldp enable //开启功能

S6(config-if-range)#rldp port loop-detect shutdown-port //设置下联环路检测，故障处理方式为端口违例

S6(config-if-range)#errdisable recovery interval 300 //设置自动恢复时间为300秒

```