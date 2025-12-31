## 题目
- 在 Windows9  上编写 C：\createfile.ps1 的 PowerShell脚本
- 创建20 个文件夹C\skills\dir01 至C:\skills\dir20
- 如果文件存在，则删除后（文件夹下的文件随着一起删除，不弹出提示框），再创建；
- 每个文件夹中创建一个与文件夹同名的文本文档，如在 dir01 目录中创建 dir01.txt 文件，每个文件的内容同主文件名，如dir01.txt 文件内容为“dir01”。

## 解
```shell
# 设置基础目录路径
$baseDirectory = "C:\skills"

# 检查基础目录是否存在，如果不存在，则创建
if (-not (Test-Path $baseDirectory)) {
    New-Item -ItemType Directory -Path $baseDirectory
}

# 循环创建 20 个文件夹及其对应文件
1..20 | ForEach-Object {
    $dirName = "dir{0:D2}" -f $_  # 格式化文件夹名字，确保是 dir01, dir02, ... dir20
    $dirPath = Join-Path $baseDirectory $dirName  # 构建完整的文件夹路径

    # 检查文件夹是否已存在
    if (Test-Path $dirPath) {
        # 如果存在，则删除（包括文件夹下所有内容），不弹出提示
        Remove-Item $dirPath -Force -Recurse
    }

    # 创建文件夹
    New-Item -ItemType Directory -Path $dirPath

    # 构建文件路径，并在文件夹内创建文本文件
    $filePath = Join-Path $dirPath "$dirName.txt"
    $content = $dirName  # 文件内容与文件名相同
    Set-Content -Path $filePath -Value $content
}
```