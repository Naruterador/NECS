##### openssl命令集合


```
openssl req -new -subj "/C=GB/CN=foo" \
                  -addext "subjectAltName = DNS:foo.co.uk" \
                  -addext "certificatePolicies = 1.2.3.4" \
                  -newkey rsa:2048 -keyout key.pem -out req.pem


openssl req -new x509 -days 7300 -subj "/C=CN/ST=Beijing/L=Beijing/O=Skills/OU=System/CN=skills.com" -addext "subjectAltName = DNS:www.skills.com" -key /etc/pki/CA/private/cakey.pem -out cacert.pem
openssl x509 -noout -text -in cacert.pem

openssl req -new -key skills.key -out skills.csr -addext "subjectAltName = DNS:www.skills.com"
openssl req -noout -text -in skills.csr



[root@localhost ssl]# cat hy.ext
subjectAltName = DNS:www.skills.com

openssl ca -keyfile /etc/pki/CA/private/cakey.pem -cert /etc/pki/CA/cacert.pem -in skills.csr -out skills.crt -extfile hy.ext
```

- 使用config文件配置CA颁发机构
```
vim req.conf
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no
[req_distinguished_name]
C = US
ST = VA
L = SomeCity
O = MyCompany
CN = server1.example.com
[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = server1.example.com


openssl req -new x509 -days 7300 -key /etc/pki/CA/private/cakey.pem -out cacert.pem -config req.conf

```


