## 题目
- 为 Linux-5 添加 4 块硬盘，每块硬盘大小为 5G，组成 Raid10，设备名称为/dev/md10，
保证服务器开机，Raid能正常工作。
```shell
mdadm -Cv /dev/md10 -l 10 -n 4 /dev/vdb /dev/vdc /dev/vdd /dev/vde
```
