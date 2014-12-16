
FROM dockerfile/nginx:latest
MAINTAINER likang

ADD nginx-auth/server-cert.pem /etc/ssl/certs/docker-registry
ADD nginx-auth/server-key.pem /etc/ssl/private/docker-registry

ADD nginx-auth/nginx.conf /etc/nginx/
ADD nginx-auth/nginx.default /etc/nginx/sites-enabled/default
ADD nginx-auth/docker-registry.htpasswd /etc/nginx/

EXPOSE 80 443
CMD ["nginx"]
