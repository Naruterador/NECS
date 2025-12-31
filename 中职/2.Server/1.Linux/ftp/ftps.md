## 题目
  - 配置 linux4 为 FTP 服务器，安装 vsftpd
  - 禁止使用不安全的 FTP，请使用“skills.com”证书颁发机构，颁发的证书，启用 FTPS 服务
  - 配置虚拟用户认证模式。虚拟用户 vuser1 和 vuser2 映射为 ftpvuser（该账户不能登录系统， 家目录为/home/ftpvdir）上传文件所有者为 ftpvuser
  - vuser1 登录 ftp 后的目录为/ftpdata/vuser1 ，vuser2 登录 ftp 后的目录/ftpdata/vuser2
  - vuser1 仅有下载权限
  - 允许 vuser2用户上传和下载文件，但是禁止上传后缀名为.exe .php的文件
  - 限制用户的下载最大速度为 100kb/s；最大同一 IP 在线人数为 2 人
  - 采用随机端口用户客户端跟服务器的数据传输,并限制传输端口为 40000-41000 之间

## 解
- 正常完成ftp虚拟用户配置
  - ftps配置
 
   ```shell
   vim /etc/vsftpd/vsftpd.conf
   rsa_cert_file=/etc/vsftpd/vsftpd.crt
   rsa_private_key_file=/etc/vsftpd/vsftpd.key
   ssl_enable=YES

   #配置完成后重启服务
   systemctl restart vsftpd
   ```
  
  - 其他参数配置

  ```shell
  #限制用户的下载最大速度为 100kb/s
  local_max_rate=100000
  
  #最大同一IP在线人数为 2 人
  max_per_ip=2

  #采用随机端口用户客户端跟服务器的数据传输,并限制传输端口为 40000-41000 之间
  pasv_min_port=40000
  pasv_max_port=41000
  ```

## 测试脚本

```shell
#ftp
cd /ftpdata/vuser1
touch test1.txt
cd /ftpdata/vuser2
touch test2.txt
cd /opt
touch test3.txt test4.exe test5.php
cat /etc/vsftpd/vusers | tee /root/${out_f}ftp.txt
cat /etc/pam.d/vsftpd | tee -a /root/${out_f}ftp.txt

cat /var/ftp/virtualusers/vuser1 | tee -a /root/${out_f}ftp.txt
cat /var/ftp/virtualusers/vuser2 | tee -a /root/${out_f}ftp.txt

ll /ftpdata/vuser1 | tee -a /root/${out_f}ftp.txt
ll /ftpdata/vuser2 | tee -a /root/${out_f}ftp.txt

lftp -e 'set ftp:ssl-force true; set ftp:ssl-protect-data true; open ftp://linux4.skills.com; user vuser1 Key-1122; mput test3.txt; mget test1.txt; bye' 2>&1 | tee -a /root/${out_f}ftp.txt

lftp -e 'set ftp:ssl-force true; set ftp:ssl-protect-data true; open ftp://linux4.skills.com; user vuser2 Key-1122; mput test3.txt; mget test2.txt; mput test4.exe; mput test5.php' 2>&1 | tee -a /root/${out_f}ftp.txt

cd /root

cat /etc/vsftpd/vsftpd.conf | grep pasv | tee -a /root/${out_f}ftp.txt
cat /etc/vsftpd/vsftpd.conf | grep max_per_ip | tee -a /root/${out_f}ftp.txt
cat /etc/vsftpd/vsftpd.conf | grep local_max_rate | tee -a /root/${out_f}ftp.txt
```
  
