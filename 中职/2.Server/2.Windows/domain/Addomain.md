## 快速加域指南
- 修改windows 2022 IP地址
```shell
#修改IP地址（手动）
netsh interface ipv4 set address name=”本地连接” source=static addr=10.7.10.212 mask= 255.255.255.0 gateway=10.7.10.1

#修改第一和第二DNS地址（手动）
netsh interface ip set dnsservers name="本地连接" source=static address=8.8.8.8
netsh interface ip add dnsservers name="本地连接" address=168.95.1.1
```

- 加域后修改机器名（弹出对话框，输入密码）
```shell
add-computer -newname w4 -domain skills.com -credential administrator -force -restart
```


- 修改机器名并重启
```shell
Rename-Computer -NewName windows2 -Force -restart
```

- 加入活动目录并重启计算机
```shell
netdom join windows2 /domain:skills.com /userd:administrator /passwordD:Key-1122 /reboot:5
```

## 远程加入域的配置
```shell
#在客户端开启powershell远程
Enable-PSRemoting -Force

#在服务端进行配置，加入信任主机
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "192.168.19.102" -Force
#使用*可以信任所有主机，但这会降低安全性，仅推荐在测试环境中使用。
Set-Item WSMan:\localhost\Client\TrustedHosts -Value * -Force

#在服务端查看信任主机
Get-Item WSMan:\localhost\Client\TrustedHosts

#在域控制器远程连接到客户机
Enter-PSSession -Computername 192.168.19.102 -Credential administrator

############################################################################################
$User = "administrator"
$Password = ConvertTo-SecureString -AsPlainText "Key-1122" -Force
$Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

Enter-PSSession -ComputerName 192.168.19.102 -Credential $Credential
###########################################################################################
#本加域配置在加域时不会有额外的密码弹窗口
```


## 在域控制器上远程加域（弹窗版）
```shell
$DomainCredential = Get-Credential -Message "请输入加入域的账户凭据"

$Computers = @("192.168.19.102", "192.168.19.103")
foreach ($Computer in $Computers) {
    Invoke-Command -ComputerName $Computer -Credential $DomainCredential -ScriptBlock {
        Add-Computer -DomainName "skills.com" -Credential $Using:DomainCredential -Force -Restart
    }
}
```

## 在域控制器上远程加域（不弹窗版）
```shell
# 定义用户名和密码
$username = "skills\administrator" # 请替换为实际的域用户名
$password = "Key-1122" | ConvertTo-SecureString -AsPlainText -Force # 请替换为实际的密码

# 创建凭据对象
$DomainCredential = New-Object System.Management.Automation.PSCredential($username, $password)

# 定义要加入域的计算机列表
$Computers = @("192.168.19.103", "192.168.19.104")

foreach ($Computer in $Computers) {
    Invoke-Command -ComputerName $Computer -Credential $DomainCredential -ScriptBlock {
        Add-Computer -DomainName "skills.com" -Credential $Using:DomainCredential -Force -Restart
    }
}
```

## 在域控制器上远程加域（改机器名版+弹窗版）

```shell
#使用*可以信任所有主机，但这会降低安全性，仅推荐在测试环境中使用。
Set-Item WSMan:\localhost\Client\TrustedHosts -Value * -Force
```

```shell

$DomainCredential = Get-Credential -Message "请输入加入域的账户凭据"

# 初始化计算机名的起始编号
$computerNameIndex = 3
$Computers = @("192.168.19.103", "192.168.19.104", "192.168.19.105", "192.168.19.106", "192.168.19.107", "192.168.19.108", "192.168.19.109")

foreach ($Computer in $Computers) {
    # 生成新的计算机名
    $newComputerName = "windows" + $computerNameIndex

    Invoke-Command -ComputerName $Computer -Credential $DomainCredential -ScriptBlock {
        param($newComputerName, $DomainCredential)
        # 使用Add-Computer命令加入域并同时修改计算机名
        Add-Computer -DomainName "skills.com" -Credential $DomainCredential -NewName $newComputerName -Force -Restart
    } -ArgumentList $newComputerName, $DomainCredential

    # 更新计算机名的编号，为下一台计算机准备
    $computerNameIndex++
}

```