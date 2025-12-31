## 组策略
- 除manager 组和dev组，所有用户隐藏C盘。
- 除manager 组和dev组，所有普通给用户禁止使用cmd。
- dev00用户登陆域后，会自动增加驱动器p，该驱动器自动关联windows1的C:\tools文件夹。
- sales用户组的Internet Explorer默认将代理指向linux2.skills.lan，端口号为8080。
- 所有用户都应该收到登录提示信息：标题“登录安全提示：”，内容“禁止非法用户登录使用本计算机。”
- 域内的所有计算机（除dc外），当dc服务器不可用时，禁止使用缓存登录。


- 解题方式：
  - 新建一个组策略名为mananddev，然后配置：
    - 除manager 组和dev组，所有用户隐藏C盘。
    - 除manager 组和dev组，所有普通给用户禁止使用cmd。
  - 修改manandev的委派策略，添加dev组和mananger组，将这两个组的应用策略选择为拒绝
  - 其他组策略配置直接配置在默认组策略中就行可以了
