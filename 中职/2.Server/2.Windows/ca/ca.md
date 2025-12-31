#### 将证书数据库集中存储到\\skills.com\HQ\config\ca
- 查看当前存储路径，在CA证书颁发中心，右键属性,选择存储，可以查看当前存储路径
  - Copy the database files and log files to new location. The default database path is: %SystemRoot%\System32\CertLog

- Modify the database paths in the following registry entries to reflect the new path:
  - HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\CertSvc\Configuration\DBDirectory



#### 创建计算机证书模板，命名为“ComputerTemplate”，配置该证书颁发方式为手动审批。
- 修改证书模版配置
![p2](./2022_公开卷1/pics/p2.png)
- 证书申请完成后需要到主CA的证书颁发机构进行手动证书颁发
- 证书手动颁发之后不会立即进入MMC中计算机个人证书库中，需要到证书颁发机构中导出证书，再导入MMC中
- 导出颁发的证书如下图：
![p2](./2022_公开卷1/pics/p3.png)
