#### 创建CA
```shell
mkdir /etc/pki/CA
mkdir /etc/pki/CA/private
mkdir /etc/pki/CA/newcerts
touch /etc/pki/CA/index.txt
touch /etc/pki/CA/serial
echo 01 > serial

#root cacaert.pem
openssl genrsa -out /etc/pki/CA/private/cakey.pem 2048
openssl req -new -x509 -key /etc/pki/CA/private/cakey.pem -out /etc/pki/CA/cacert.pem -days 3650
```


#### 通过CA申请skills.crt证书,并带有dns
```shell
vim /etc/pki/tls/skills.ext
basicConstraints=CA:FALSE
extendedKeyUsage=serverAuth,clientAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = skills.lan
DNS.2 = *.skills.lan




vim /etc/pki/tls/openssl.cnf
default_days    = 1825                  # how long to certify for


#apply cacertificate
openssl genrsa -out skills.key 2048
openssl req -new -key skills.key -out skills.csr
openssl ca -keyfile /etc/pki/CA/private/cakey.pem -cert /etc/pki/CA/cacert.pem -in skills.csr -out skills.crt -config openssl.cnf -extfile skills.ext


#check cacertificate status
openssl x509 -noout -text -in /etc/pki/tls/skills.lan
```

#### 证书转换
```shell

key and crt to pfx
openssl pkcs12 -export -out skills.pfx -inkey skills.key -in skills.crt

pfx to pem
openssl pkcs12 -in skills.pfx -out skills.pem -nodes


pem to crt and key
#方法1:
openssl rsa -outform der -in skills.pem -out apache.key
openssl x509 -outform der -in skills.pem -out apache.crt

#方法2:
openssl pkey -in skills.pem -out apache.key
openssl x509 -in skills.pem -out apache.crt 
```

