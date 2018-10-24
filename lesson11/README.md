# Вебинар 11. Мосты, туннели и VPN

## Домашнее задание

VPN

1. Между двумя виртуалками поднять vpn в режимах

- tun

- tap

Прочуствовать разницу.

2. Поднять RAS на базе OpenVPN с клиентскими сертификатами, подключиться с локальной машины на виртуалку

3. __*__ Самостоятельно изучить, поднять ocserv и подключиться с хоста к виртуалке

## Выполнение

1. tun/tap туннели

* Gre туннель между nodetap1 и nodetap2

Запускаем:

```
vagrant up nodetap1 && vagrant up nodetap2
```

```
[vagrant@nodetap1 ~]$ ip neigh 
192.168.1.2 dev tap0 lladdr 5e:2b:e2:04:f3:3d STALE
192.168.0.20 dev eth1 lladdr 08:00:27:7e:14:cf STALE
10.0.2.2 dev eth0 lladdr 52:54:00:12:35:02 REACHABLE
10.0.2.3 dev eth0 lladdr 52:54:00:12:35:03 STALE

[vagrant@nodetap2 ~]$ ip neigh 
192.168.1.1 dev tap0 lladdr e6:c0:57:83:b0:9c STALE
10.0.2.3 dev eth0 lladdr 52:54:00:12:35:03 STALE
10.0.2.2 dev eth0 lladdr 52:54:00:12:35:02 REACHABLE
192.168.0.10 dev eth1 lladdr 08:00:27:9e:fb:c1 STALE
```

* Gre туннель между nodetun1 и nodetun2

Запускаем:

```
vagrant up nodetun1 && vagrant up nodetun2
```

```
[vagrant@nodetun1 ~]$ ip neigh 
192.168.0.40 dev eth1 lladdr 08:00:27:f3:38:fd REACHABLE
10.0.2.2 dev eth0 lladdr 52:54:00:12:35:02 REACHABLE
192.168.0.10 dev eth1 lladdr 08:00:27:9e:fb:c1 STALE
[vagrant@nodetun1 ~]$ ip route
default via 10.0.2.2 dev eth0 proto static metric 100 
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100 
192.168.0.0/24 dev eth1 proto kernel scope link src 192.168.0.30 metric 100 
192.168.1.2 dev tun0 proto kernel scope link src 192.168.1.1 

[vagrant@nodetun2 ~]$ ip neigh 
192.168.0.30 dev eth1 lladdr 08:00:27:ce:47:f7 DELAY
10.0.2.2 dev eth0 lladdr 52:54:00:12:35:02 REACHABLE
[vagrant@nodetun2 ~]$ ip route
default via 10.0.2.2 dev eth0 proto static metric 100 
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100 
192.168.0.0/24 dev eth1 proto kernel scope link src 192.168.0.40 metric 100 
192.168.1.1 dev tun0 proto kernel scope link src 192.168.1.2 
```

2. Openvpn

Запускаем:

```
vagrant up nodeopenvpn
```

Копируем ключи с сервера:

```
PRIVATEKEY=./.vagrant/machines/nodeopenvpn/virtualbox/private_key && \
rsync -Pav -e "ssh -i $PRIVATEKEY" vagrant@10.10.10.5:/etc/openvpn/cert/ca/ca.crt ./ && \
rsync -Pav -e "ssh -i $PRIVATEKEY" vagrant@10.10.10.5:/etc/openvpn/cert/client1/client1.crt ./ && \
rsync -Pav -e "ssh -i $PRIVATEKEY" vagrant@10.10.10.5:/etc/openvpn/cert/client1/client1.key ./ && \
rsync -Pav -e "ssh -i $PRIVATEKEY" root@10.10.10.5:/etc/openvpn/cert/server/ta.key ./
```

Подключаемся:

```
openvpn --config openvpn-client.conf
```

3. Ocserv

Запускаем:

```
vagrant up nodeocserv
```

Копируем ключи с сервера:

```
PRIVATEKEY=./.vagrant/machines/nodeocserv/virtualbox/private_key && \
rsync -Pav -e "ssh -i $PRIVATEKEY" root@10.10.10.10:/etc/pki/ocserv/cacerts/ca.crt ./ && \
rsync -Pav -e "ssh -i $PRIVATEKEY" root@10.10.10.10:/vagrant/client1.key ./ && \
rsync -Pav -e "ssh -i $PRIVATEKEY" root@10.10.10.10:/vagrant/client1.crt ./
```

Подключаемся:

```
sudo openconnect https://10.10.10.10 -u client1 -k client1.key -c client1.crt --cafile ca.crt
```

**Примечание:** пароль "somepass", задается в Vagrantfile. Естественно не безопасно так делать, это исключительно для стенда.:
