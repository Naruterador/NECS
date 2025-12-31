#### 编写脚本实现服务器在线状态监测，HQ-Server1、HQ-Server2 服务器启动或关机时自动向 http://status.skills.com 报告上、下线状态，站点运行在 HQ-DC上运行效果图如下:

![p4](../../pics/p4.png)

- script(第一版一直检测)
```ps1
$serverNames = @("HQ-Server1", "HQ-Server2")
$outputFile = "\\hq-serverl\web\index. html"

"<html>`n <pre>" | Out-File -FilePath $outputFile

while ($true) {
	foreach ($serverName in $serverNames) {
	$online = Test-Connection -ComputerName $serverName -Count 1 -Quiet
	$currentTime = Get-Date -Format "yyyy/MM/dd HH:mm:ss
	
		if ($online) {
			$statusMessage = "$currentTime $serverName 已启动上线"
		}
		else{
			$statusMessage = "$currentTime $serverName 已关机下线"
		}
	
	"$statusMessage" | Out-File -FilePath $outputFile -Append
	}

	Start-Sleep -Seconds 5
}	
```

- script(第二版状态检测)
```ps1
$serverNames = @{
"HQ-Server1" = "192.168.10.1"
"HQ-Server2" = "192.168.10.2"
}

$outputFile = "\\hq-server1\web\index.html"
$previousStatus = @{ }

"<html> 'n<pre>" | Out-File -FilePath $outputFile

foreach ($serverName in $serverNames.Keys){
	$serverIP = $serverNames[$serverName]
	$online = Test-Connection - ComputerName $serverIP -Count 1 -Quiet
	$currentTime = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
	
	if ($online){
		$statusMessage = "$currentTime $serverName 已启动上线"
	}
	else{
		$statusMessage = "$currentTime $serverName 已关机下线"
	}
	
	$previousStatus[$serverName] = $online
	"$statusMessage" | Out-File -FilePath $outputFile -Append
}

while($true){
	foreach ($serverName in $serverNames.Keys){
	$serverIP = $serverNames[$serverName]
	$online = Test-Connection -ComputerName $serverIP -Count 1 -Quiet
	$currentTime = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
	
		if(-not $previousStatus.ContainsKey($serverName)){
			$previousStatus[$serverName] = $online
		}
		elseif($online -ne $previousStatus[$serverName]){
			if($online){
				$statusMessage = "$currentTime $serverName 已启动上线"
			}
			else{
				$statusMessage = "$currentTime $serverName 已关机下线"
			}
		$previousStatus[$serverName] = $online
		"$statusMessage" | Out File -FilePath $outputFile -Append
		}
	}
	Start-Sleep -Seconds 5
}
```
- 在IIS服务器设置每秒刷新页面
- 选择站点，在右边工具中，选择HTTP 响应标头
![p5](../../pics/p5.png)
- 右键选择添加,在 "名称" 列中输入 "Refresh"。在 "值" 列中输入刷新时间，以秒为单位。例如，如果要设置每 5 分钟刷新一次，输入 "300"。
![p6](../../pics/p6.png)
