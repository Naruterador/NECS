## 题目
- 利用windows操作系统powershell
- 编写 C:\createfile.psl 的 PowerShell 脚本
- 创建 50个文件c:\file\file01.txt 至 C:\file\file50.txt
- 如果文件存在，则删除后，再创建每个文件的内容同主文件名，如file01.txt 文件的内容为“file01”

```shell

$targetDirectory = "C:\file"
$fileCount = 50

# 确保目标目录存在，不存在则创建
if (-not (Test-Path -Path $targetDirectory)) {
    New-Item -ItemType Directory -Path $targetDirectory
}

for ($i = 1; $i -le $fileCount; $i++) {
    $fileName = "file{0:D2}.txt" -f $i
    $filePath = Join-Path -Path $targetDirectory -ChildPath $fileName
    
    # 创建或覆盖文件，写入内容
    $fileContent = $fileName.Substring(0, $fileName.Length - 4)
    Set-Content -Path $filePath -Value $fileContent
}


```
