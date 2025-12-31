## 解决有关Rocky linux 9.1没有db_load指令的问题:
```shell
yum install libdb-utils
```


- FTP是File Transfer Protocol文件传输协议的英文名称，用于在internet上控制文件的双向传输，同时它也是一个应用程序。
  - 具体作用（传文件）
- 一些配置说明:

```shell
#下载服务
yum install vsftpd* ftp* -y
#重启服务
systemctl restart vsftpd


#主配置文件，核心配置文件
/etc/vsftpd/vsftpd.conf

#不允许匿名用户登录
anonymous_enable=NO

#允许本地用户
local_enable=YES		

#(空闲多少秒自动断线)	空闲自动断线
idle_session_timeout=600

#设置连接上限
max_clients=[连接上限]		

userlist_deny=yes(黑名单) no（白名单）

userlist_file=[黑名单名称]

user_config_dir=[本地用户名单目录（配置文件）]

cd /etc/vsftpd
mkdir [本地用户目录]

cd [目录]
vi [用户名]

local_root=[宿主主目录]

/etc/vsftpd/ftpusers 		#黑名单，这个里面的用户不允许访问FTP服务器
/etc/vsftpd/user_list 		#白名单，允许访问FTP服务器的用户列表
/var/ftp/pub   			    #vsftpd的根目录（修改目录权限，让其他用户可以读写上传。）
```

- 匿名用户的基本配置：
 - 使用匿名FTP，用户无需输入用户名密码即可登录FTP服务器，vsftpd安装后默认开启了匿名ftp的功能，用户无需额外配置即可使用匿名登录ftp服务器。
 - 匿名ftp的配置在/etc/vsftpd/vsftpd.conf中设置。
 - 备注：这个时候任何用户都可以通过匿名方式登录ftp服务器，查看并下载匿名账户主目录下的各级目录和文件，但是不能上传文件或者创建目录。


 ```shell
anonymous_enable=NO//默认即为NO		#(默认）不允许匿名用户登录

#权限修改命令
anonymous_enable=YES			#接受匿名用户
write_enable=YES				#允许读写
anon_upload_enable=YES			#允许上传
no_anon_password=YES			#匿名用户login时不询问口令
anon_root=可以自己创建目录	    #匿名用户主目录
```



- 配置本地用户登录：
```shell
#1.创建ftptest用户
useradd ftptest 				#创建ftptest用户
passwd ftptest 				    #修改ftptest用户密码

#2.修改/etc/vsftpd/vsftpd.conf
vi /etc/vsftpd/vsftpd.conf
local_enable=YES				#接受本地用户
local_root=创建自己的目录		#本地用户主目录（存放东西的目录）//指定路径

cd /etc/vsftpd
mkdir [文件名]
vi [用户名]

```


- 配置虚拟用户登录：

```shell
vi /etc/vsftpd/vsftpd.conf
guest_enable=yes          			#允许虚拟用户登录
guest_username=自己创建		     	#指定本地用户
user_config_dir=可以自己创建    	#存放虚拟用户文件（配置文件）
allow_writeable_chroot=yes 			#允许读写更改目录（宿主目录）			
#创建本地用户 xuni（不要给密码）

cd /etc/vsftpd（必须在这）			
vi  文件				#(创建文件 虚拟用户名 密码)
db_load -T -t hash -f 文件 文件.db(文件格式)（改成数据库格式）

#指向并认证数据库文件（虚拟用户与本地用户进行关联）
vi /etc/pam.d/vsftpd
#把原先的所有行数前加上#号
auth required pam_userdb.so db=/etc/vsftpd/文件
account required pam_userdb.so db=/etc/vsftpd/文件

#编辑虚拟用户的权限：
mkdir 虚拟用户配置文件目录
cd 目录         
vi 文件（虚拟用户名字）
local_root=宿主目录			 #允许浏览目录
anon_upload_enable=yes		 #允许上传文件
anon_mkdir_write_enable=yes	 #允许创建
anon_other_write_enable=yes	 #允许其他操作
download_enable=YES    		 #是否允许下载 
deny_file={*.txt,*.exe}		 #禁止上传后缀名为.txt,.exe的文件
：wq
chmod 777 /文件

mkdir -p 宿主目录			#创建宿主主目录（存放虚拟用户东西的目录 虚拟用户权限指定文件是这个）
chmod 777 宿主目录		    #设置权限使之可以上传读写

```


- 用户权限控制 （指令）：
```shell
anon_upload_enable=YES    		#设置是否允许匿名用户上传文件 
anon_other_write_enable=YES    	#设置匿名用户是否有修改删除的权限 
anon_world_readable_only=YES    #当为YES时，文件的其他人必须有读的权限才允许匿名用户下载，单单所有者为ftp且有读权限是无法下载的，必须其他人也有读权限，才允许下载
write_enable=YES			    #可以上传(全局控制)
file_open_mode=0666		        #上传文件的权限配合umask使用

local_root=/home        		#设置本地用户的根目录 (允许浏览目录）
write_enable=YES        		#是否允许用户有写权限 
download_enbale=YES    		    #是否允许下载 
chown_upload=YES        		#设置匿名用户上传文件后修改文件的所有者 
chown_username=ftpuser    		#与上面选项连用，表示修改后的所有者为ftpuser( 匿名上传文件所属用户名)
ascii_upload_enable=YES    		#设置是否允许使用ASCII模式上传文件 
ascii_download_enable=YES    	#设置是否允许用ASCII模式下载文件


#虚拟用户权限指令：
 local_root=目录			#允许浏览目录
 write_enable=YES			#允许更改文件
 anon_world_readable_only=no	#允许下载,当参数设置为YES时，需要其他人（Ｏ权限），拥有只读权限才能下载，当配置为NO时，只需要所有者（U权限）拥有读权限就能下载
 anon_umask=022
 anon_world_readable_only=NO	#关闭只可读
 anon_upload_enable=YES		    #允许上传
 anon_mkdir_write_enable=YES	#允许创建目录
 anon_other_write_enable=YES	#其他写权限，改，删（此行改为NO后，便没有了删除权限，其他权限不变）
 cmds_allowed=FEAT,REST,CWD,LIST,MDTM,MKD,NLST,PASS,PASV,PORT,PWD,QUIT,RMD,SIZE,STOR,TYPE,USER,ACCT,APPE,CDUP,HELP,MODE,NOOP,REIN,STAT,STOU,STRU,SYST,RETR    #允许那些命令可以执行
 cmds_denied=DELE		#不允许执行删除文件命令
```


- pam文件详解：
  - 工作类别:
    - auth: 主要负责验证使用者身份以及用户权限授予; 例如你的验证方式有很多比如一次性密码、指纹、虹膜等等，都应该添加在 auth 下以及比如赋给用户某个组的组员身份等等。
    - account: 主要负责在用户能不能使用某服务上具有发言权，但不负责身份认证; 例如验证帐户的此操作是否已经过期,权限多大,拥有此权限的时间期限是否已经过期等等
    - password: 主要负责和密码有关的工作; 例如控制密码的使用期限，重复输入的次数，密码锁定后的解禁时限以及保存密码的加密放方式等; (等保必须要做的) 
    - session: 主要负责对每个会话进行跟踪和记录，例如记录的内容包括登录的用户名及登录的时间和次数等等

  - 控制模式:
    - required: 当使用此控制标志时，当验证失败时仍然会继续进行其下的验证过程，它会返回一个错误信息，但是由于它不会由于验证失败而停止继续验证过程，因此用户不会知道是哪个规则项验证失败;
    - requisite: 与required 的验证方式大体相似，但是只要某个规则项验证失败则立即结束整个验证过程，并返回一个错误信息。使用此关键字可以防止一些通过暴力猜解密码的攻击，但是由于它会返回信息给用户，因此它也有可能将系统的用户结构信息透露给攻击者。
    - sufficient: 只要有此控制标志的一个规则项验证成功，那么 PAM 构架将会立即终止其后所有的验证，并且不论其前面的 required 标志的项没有成功验证，它依然将被忽略然后验证通过。
    - optional: 表明对验证的成功或失败都是可有可无的，所有的都会被忽略
    - include: 将其他配置文件中的流程栈包含在当前的位置，就好像将其他配置文件中的内容复制粘贴到这里一样。
    - substack：运行其他配置文件中的流程，并将整个运行结果作为该行的结果进行输出。该模式和 include 的不同点在于认证结果的作用域：如果某个流程栈 include 了一个带 requisite 的栈，这个 requisite 失败将直接导致认证失败同时退出栈；而某个流程栈 substack 了同样的栈时，requisite 的失败只会导致这个子栈返回失败信号，母栈并不会在此退出。


- 设置ftp本地用户和虚拟用户能同时登陆
  - 题目：
    - 任务描述：请采用FTP服务器，实现文件安全传输。
    - 配置linux2为FTP服务器，安装vsftpd，新建本地用户xiaoming，本地用户登陆ftp后的目录为/var/ftp/pub，可以上传下载。
    - 配置ftp虚拟用户认证模式，虚拟用户ftpuser1和ftpuser2映射为ftp，ftpuser1登录ftp后的目录为/var/ftp/vdir/ftpuser1，可以上传下载,禁止上传后缀名为.exe的文件；ftp2登录ftp后的目录为/var/ftp/vdir/ftpuser2，仅有下载权限。
    - 使用ftp命令在本机验证。
```shell
#在配置好本地用户和虚拟用户的基础上
vi /etc/pam.d/vsftpd
#第二行添加
auth sufficient pam_userdb.so db=/etc/vsftpd/虚拟账户文件
account sufficient pam_userdb.so db=/etc/vsftpd/虚拟账户文件

#在虚拟目录用户中添加本地用户xiaoming
vi xiaoming
local_root=/var/ftp/pub			#允许浏览目录
anon_world_readable_only=NO	#允许下载,当参数设置为YES时，需要其他人（Ｏ权限），拥有只读权限才能下载，当配置为NO时，只需要所有者（U权限）拥有读权限就能下载
anon_upload_enable=YES		    #允许上传
#添加这段配置是为了能让xiaoming用户实现上传下载，但是实际用户其实还是映射到ftp
```
