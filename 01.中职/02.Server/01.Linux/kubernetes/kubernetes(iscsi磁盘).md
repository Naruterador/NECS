## 问题：
- 1.在 linux5-linux7 上安装 containerd 和 kubernetes，linux5 作为 masternode， linux6 和 linux7 作为 worknode；使用 containerd.sock 作为容器 runtime-endpoint。master节点配置 calico 作为网络组件。

- 2.导入 nginx.tar 镜像，利用linux8的iscsi磁盘，创建持久卷,将nginx容器中的网页根目录挂载到pv卷中,主页内容为“HelloPV”。用该镜像创建一个名称 为 web 的 deployment，副本数为 2；为该 deployment 创建一个类型为 nodeport 的 service，port 为 80，targetPort 为 80，nodePort 为 30080
## 解：
- 题目1已经做好，nginx镜像导入后改docker.io/library/nginx:9.2
- linux8上iscsi已经做好,linux6和linux7上已经下载iscsi-initiator并改好文件

- 在linux6和linux7上连接iscsi

```
iscsiadm -m discovery -t st -p 10.90.40.108
iscsiadm -m node -T iqn.2024-01.lan.skills:server -p 10.90.40.108 -l
mkfs.ext4 /dev/sda
```

- 在linux6上做

```
mkdir /a
mount /dev/sda /a
echo HelloPV > /a/index.html
```

- 在linux5上

```
cd /opt
vi pv.yaml

apiVersion: v1
kind: PersistentVolumne
metadata:
	name: nginx-pv
spec:
	capacity:
		storage: 20Gi
	accessModes:
		- ReadWriteMany
	persistentVolumeReclaimPolicy: Retain
	storageClassName: iscsi-static
	iscsi:
		targetPortal: 10.90.40.108:3260
		iqn: iqn.2024-01.lan.skills:server
		lun: 0
		faType: ext4
		readOnly: false
```

```
vi pvc.yaml

apiVersion: v1
kind: PersistentVolumneClaim
metadata:
	name: nginx-pvc
spec:
	accessModes:
		- ReadWriteMany
	resources:
		requests:
			storage: 20Gi
	storageClassName: iscsi-static
	volumeName: nginx-pv
```

```
vi deploy.yaml

apiVersion: apps/v1
kind: Deployment
metadata：
	name: web
spec:
	replicas: 2
	selector:
		matchLabels：
			app: web
	template:
		metadata:
			labels:
				app: web
		spec:
			containers:
			- name: nginx
			  image: docker.io/library/nginx:9.2
			  ports:
			  - containerPort: 80
			  volumeMounts:
			  - name: web-content
				    mountPath: /usr/share/nginx/html
			volumes:
			- name: web-content
			  persistentVolumeClaim:
				  claimName: nginx-pvc
```

```
vi service.yaml

apiVersion: v1
kind: Service
metadata:
	name: web
spec:
	type: NodePort
	ports:
	  - name: http
	    port: 80
	    targetPort: 80
	    nodePort: 30080
	selector:
		app: web
```

```
kubectl create -f pv.yaml
kubectl create -f pvc.yaml
kubectl create -f deploy.yaml
kubectl create -f service.yaml

kubectl get pv
kubectl get pvc
kubectl get pods -o wide

curl linux5.skills.lan:30080
```