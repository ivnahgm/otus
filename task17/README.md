# Вебинар 18. LDAP. Централизованная авторизация и аутентификация

## Домашнее задание

LDAP

1. Установить FreeIPA

2. Написать playbook для конфигурации клиента

3. Всю "сетевую лабораторию" перевести на аутентификацию через LDAP

4. __*__ Настроить авторизацию по ssh-ключам

В git - результирующий playbook

## Выполнение

1. Полностью переделана сетевая лаборатория под настройку через ansible, роли **otus_netlab_gateway**, **otus_netlab_router** и **otus_netlab_simple**.

Для настройки ipa сервера и клиентов созданы роли **ipa_client**, **ipa_server** и **ipa_user_manage** (создание пользователей).

После развертывания стенда с помощью vagrant, запустите:

```
    ansible-playbook ipa.yml -i ./.vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory
```

Для тестирования авторизации по ssh-ключам, с помощью роли ipa_user_manage создаются два пользователя: bob и joe.