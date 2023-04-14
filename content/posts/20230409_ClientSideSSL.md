---
title: "HowTo: Client side SSL"
date: 2023-04-09T13:28:47+02:00
draft: false
---

## Wozu das ganze?

Ich will auf meinem Server selbst geschriebene WebApps laufen lasse. Dort will ich mich nicht mit Nutzerverwaltung/-authorisierung rumschlagen, weil ich bin eh der einzig. Ich will aber auch keine ungesicherten Sachen im Web rumstehen habe ... weil da evtl. Infos zu meiner Wohnung gefunden werden können.

Daher will ich für jedes Gerät das auf den Server zugreifen will ein Clientzertifikat. Dieses wird von einem Nginx als Proxy für meine Spielereien geprüft. Und ich kann dann mobil von überall zugreifen :-)

## Voraussetzungen

Ein Nginx welches ein SSL-Zertifikat(für eine sichere Verbindung im allgemeinen und speziell für Webseiten die von allen genutzt werden können sollen) hat. Dieses wird von CertBot via LetsEncrypt up-to-date gehalten. Der DNS-Name wird über den Dyndnsdienst von Strato und meiner Fritzbox gemanagt.

## Was ich gemacht habe

Das [hier](https://viktorbarzin.me/blog/13-client-side-certificate-authentication-with-nginx/) gelesen. Und dann mit minimalen Änderungen bei mir implementiert.

Zuerst machen wir den Server zu seiner eigenen Zertifikatauthorität. D.h. der verifiziert sich lokal selber. Dazu lege ich einen privaten ca.key im Konfigurationsverzeichnis von Nginx(gibt bestimmt bessere Orte, aber bah ...) an:

````bash
cd /etc/nginx
openssl genrsa -aes256 -out ca.key 4096
````

Jetzt noch den öffenlichen Schlüssel anlegen ... und weil wir es sind lassen wir ihn 99999 Tage gültig sein. Hoffentlich beißt mich das nicht irgendwann in den Hintern ;-).

````bash
openssl req -new -x509 -days 99999 -key ca.key -out ca.crt
-> Country Name (2 letter code) [AU]:DE
-> State or Province Name (full name) [Some-State]:Bavaria
-> Locality Name (eg, city) []:Neuendettelsau
-> Organization Name (eg, company) [Internet Widgits Pty Ltd]:.
-> Organizational Unit Name (eg, section) []:.
-> Common Name (e.g. server FQDN or YOUR name) []:.
-> Email Address []:jwupf@gmx.net
````

Das muss ich evtl. nochmal wiederholen und dem Zertifikat einen vernünftigen CN(wie *hc4fire.jwupf.net*) verpassen. Aktuell ist der CN leer, was für **dieses** Zertifikat funktional OK ist.

Für jedes Gerät muss jetzt ein eigener, privater Schlüssel angelegt werden:

````bash
openssl genrsa -aes256 -out homepc.key 4096
````

Jetzt muss man eine Certificate Signing Request (CSR) anlegen ... damit kann man sich vom Server(machen wir per Hand) ein Authorisierungszertifikat erstellen lassen:

````bash
openssl req -new -key homepc.key -out homepc.csr                       
-> Country Name (2 letter code) [AU]:DE
-> State or Province Name (full name) [Some-State]:Bavaria
-> Locality Name (eg, city) []:Neuendettelsau
-> Organization Name (eg, company) [Internet Widgits Pty Ltd]:.
-> Organizational Unit Name (eg, section) []:
-> Common Name (e.g. server FQDN or YOUR name) []:Jörg Wunderlich-Pfeiffer
-> Email Address []:jwupf@gmx.net

-> A challenge password []:
-> An optional company name []:
````

Diesmal muss der CN ausgefüllt sein ... evtl. hätte ich hier den Gerätenamen nehmen sollen. Naja, beim nächsten mal.

Jetzt das Teil auf den Server kopieren:

````bash
scp homepc.csr hc4fire:/home/bobjob/homepc.csr
````

Jetzt für den CSR ein Authorisierungszertifikat erstellen:

````bash
sudo openssl x509 -req -days 9999 -in /home/bobjob/homepc.csr -CA /etc/nginx/ca.crt -CAkey /etc/nginx/ca.key -set_serial 01 -out /home/bobjob/homepc.crt
````

Jetzt das Authorisierungszertifikat vom Server holen:

````bash
scp hc4fire:/home/bobjob/homepc.crt homepc.crt
````

Und öffentlichen Teil von der Zertifikatauthorität:

````bash
scp hc4fire:/etc/nginx/ca.crt ca.crt
````

Das ca.crt und homepc.crt installieren wir uns jetzt auf dem Rechner(Kontextmenü des Windowsexplorer).

Man kann das ganze auch noch in ein transportables Format(PFX) zusammen legen:

````bash
openssl pkcs12 -export -out homepc.pfx -inkey homepc.key -in homepc.crt -certfile ca.crt
````

**Neustarten** aller Browser in Win11 nötig, die bekommen sonst nicht mit, das es neue Zertifikate gibt.
