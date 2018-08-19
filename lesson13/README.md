# Вебинар 13. DNS - настройка и обслуживание

## Домашнее задание

настраиваем split-dns:

* взять стенд https://github.com/erlong15/vagrant-bind

* добавить еще один сервер client2

* завести в зоне dns.lab имена:

    * web1 - смотрит на клиент1

    * web2 смотрит на клиент2

* завести еще одну зону newdns.lab

* завести в ней запись www - смотрит на обоих клиентов

* настроить split-dns:

    * клиент1 - видит обе зоны, но в зоне dns.lab только web1

    * клиент2 видит только dns.lab

* __*__) настроить все без выключения selinux, ddns тоже должен работать без выключения selinux


## Выполнение

1. [Vagrantfile](1/Vagrantfile)

    * добавлен сервер client2
    * в зоне dns.lab добавлены 2 записи: web1 и web2
    * добавлена зона newdns.lab с записью www, которая смотрит на на обоих клиентов

2. [Vagrantfile](2/Vagrantfile), split-dns

    * client - видит зоны dns.lab и newdns.lab
    * в зоне dns.lab заведена только запись web1 -> client
    * client2 видит только зону newdns.lab

*Примечание: selinux настроен*