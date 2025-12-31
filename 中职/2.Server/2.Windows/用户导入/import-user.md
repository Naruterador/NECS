#### users.csv格式
```txt
username,password
user01,Qwer@123
user02,Qwer@123
user03,Qwer@123
user04,Qwer@123
user05,Qwer@123
user06,Qwer@123
user07,Qwer@123
```
- 可以在powershell中使用import-Csv users.csv检查csv文件格式




#### import-users.ps1格式
```ps1
Import-Module ActiveDirectory

$Domain = "@skills.com"
$UserOu = "OU=Users,DC=skills,DC=com"
$NewUsersList = Import-CSV "c:\users.csv"

ForEach ($User in $NewUsersList) 
{
$givenName = $User.username
$sAMAccountName = $User.username
$userPrincipalName = $User.username + $Domain
$userPassword = ConvertTo-SecureString -AsPlainText $User.password -Force
$expire = $null

New-ADUser -Name $givenName -AccountPassword $userPassword -GivenName $givenName  -SamAccountName $sAMAccountName -UserPrincipalName $userPricipalName -Enabled $true
}
```
