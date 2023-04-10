---
title: "HowTo: Client side SSL"
date: 2023-04-09T13:28:47+02:00
draft: false
---


https://viktorbarzin.me/blog/13-client-side-certificate-authentication-with-nginx/

```bash
cd /etc/nginx
openssl genrsa -aes256 -out ca.key 4096
<-password, siehe dieser Eintrag

openssl req -new -x509 -days 99999 -key ca.key -out ca.crt
-> Country Name (2 letter code) [AU]:DE
-> State or Province Name (full name) [Some-State]:Bavaria
-> Locality Name (eg, city) []:Neuendettelsau
-> Organization Name (eg, company) [Internet Widgits Pty Ltd]:.
-> Organizational Unit Name (eg, section) []:.
-> Common Name (e.g. server FQDN or YOUR name) []:.
-> Email Address []:jwupf@gmx.net

sign user  key:
openssl x509 -req -days 9999 -in /home/bobjob/zeitz.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out /home/bobjob/zeitz.crt
```