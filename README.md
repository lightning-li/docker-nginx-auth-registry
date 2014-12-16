docker-nginx-auth-registry
==========================

通过nginx对私有仓库的安全认证

1.在宿主机上用htpasswd生成用户名和密码，作为nginx basic auth 的用户名和密码
htpasswd -b -c -d docker-registry.htpasswd kiss test

2.在宿主机上做好https自签名证书(参见https://medium.com/@deeeet/building-private-docker-registry-with-basic-authentication-with-self-signed-certificate-using-it-e6329085e612）
echo 01 > ca.srl

openssl genrsa -des3 -out ca-key.pem 2048 

openssl req -new -x509 -days 365 -key ca-key.pem -out ca.pem


openssl genrsa -des3 -out server-key.pem 2048

openssl req -subj /CN=lightningli.co -new -key server-key.pem -out server.csr

openssl x509 -req -days 365 -in server.csr -CA ca.pem -CAkey ca-key.pem -out server-cert.pem 

We should remove the passphrase from server key:

openssl rsa -in server-key.pem -out server-key.pem


3.用nginx容器中配好https服务
cp docker-registry.htpasswd /etc/nginx/

cp server-cert.pem /etc/ssl/certs/docker-registry

cp server-key.pem /etc/ssl/private/docker-registry


4.编写nginx配置文件（参见 https://github.com/docker/docker-registry/tree/master/contrib/nginx）

cp nginx.conf /etc/nginx

cp nginx.default /etc/nginx/sites-enabled/default


5.将ca证书导入docker宿主机

cat ca.pem >> /etc/ssl/certs/ca-certificates.crt

service docker restart


6.测试

docker run -d --name registry -p 5000:5000 registry

docker run -d --name lknginx --hostname lightningli.co -p 443:443 --link registry:registry
lightningli0504/docker-nginx-auth-registry

docker tag scratch lightningli.co/scratch 

记得修改/etc/hosts 添加：
127.0.0.1 lightningli.co

docker login -u kiss -p test lightningli.co

docker push lightningli.co/scratch


