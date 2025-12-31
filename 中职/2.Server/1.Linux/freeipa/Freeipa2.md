## 题目
  - 1.在linux9上安装FreeIPA-server端，域名服务器及时间服务器指向linux1，IPA服务名称: ipa.skills.com ，Domain name: skills.com，Realm name:SKILLS.COM，防火墙放开相应服务端口。
  - 2.在linux7~linux8上安装FreeIPA-client端，将客户端主机加入域：SKILLS.COM。
  - 3.在服务器端添加test用户，密码：Pass-1234， 修改或添加其他用户相关属性：姓: skills、名: cz、添加邮件地址: test@qq.com、电话号码: 0519-85334291、职称: 高级工程师、组织单位: SKILLS。
  - 4.在服务器端添加角色：skills，test用户及linux7主机归属其中。
  - 5.在服务器端添加HBAC规则：test，规则test实现test用户可以ssh到linux7，不能SSH到linux8。
  - 6.在linux8上安装VSFTP，修改上题test规则，使test用户可以ftp连接到linux8。
  - 7.在linux8上使用域账号test@SKILLS.COM下载票据，在linux9上使用域账号test@SKILLS.COM下载票据。


## 解
- 7.在linux8上使用域账号test@SKILLS.COM下载票据，在linux9上使用域账号test@SKILLS.COM下载票据。
```shell
#在Linux8上使用域账号下载票据： 使用kinit命令在Linux8上下载票据：
kinit test@SKILLS.COM

#在Linux9上使用域账号下载票据： 使用kinit命令在Linux9上下载票据：
kinit test@SKILLS.COM
```