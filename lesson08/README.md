# Вебинар 8. Управление пакетами. Дистрибьюция софта

## Домашнее задание

Размещаем свой RPM в своем репозитории:

1. Создать свой RPM (можно взять свое приложение, либо собрать к примеру апач с определенными опциями)

2. Создать свой репо и разместить там свой RPM. Реализовать это все либо в вагранте, либо развернуть у себя через nginx и дать ссылку на репо

3. __*__ Реализовать дополнительно пакет через docker

## Решение

1. Собран rpm пакет с прокси сервером dante. Для основы использовался spec-файл, поставляемый в [архиве](https://www.inet.no/dante/files/dante-1.4.2.tar.gz) с исходниками. В свой [Spec-файл](dante.spec) добавлены флаги сборки только сервера и конфиги для systemd.

2. Создан свой репозитарий с созданным пакетом, размещенный по [адресу](http://80.211.97.226/CentOS/7/os/x86_64/)

3. Создан [Dockerfile](Dockerfile) с прокси сервером dante.