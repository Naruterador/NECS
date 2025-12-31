]## 配置windows 2022 Server作为NTP服务器
#### 服务器端配置
- 修改注册表项
  - HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Parameters\Type
    - 鼠标双击 Type 文件,弹出对话框，在 数据数值（V）项输入 NTP,单击确定
  - HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Config\AnnounceFlags
    - 双击AnnounceFlags文件；在 编辑DWORD 值 的 数值数据 框中键入 5 （允许别人同步我） ，然后单击 确定按钮。
  - HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpServer\Enabled
    - 双击 Enabled文件；在 编辑DWORD 值 的 数值数据 框中键入 1 (0是关闭，1是启动)，然后单击 确定 按钮。
  - 重启服务
    ```shell

    net stop w32time                   关闭NTP服务
   
    net start w32time                  启动NTP服务
    ```
- 配置组策略开启NTP
  - 组策略路径为：计算机配置\管理模板\系统\windows 时间服务\时间提供程序;双击 启用 Windows NTP 服务器，显示状态已启用即可；
  - 刷新组策略

#### 服务端配置
- windows 2022
![p1](../../Pics/p1.png)
