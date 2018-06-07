# Вебинар 6. Инициализация системы. Systemd и SysV

## Домашнее задание

Systemd

1. Написать сервис, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова. Файл и слово должны задаваться в /etc/sysconfig
2. Из epel установить spawn-fcgi и переписать init-скрипт на unit-файл. Имя сервиса должно так же называться.
3. Дополнить юнит-файл apache httpd возможностью запустить несколько инстансов сервера с разными конфигами
4. __*__ Скачать демо-версию Atlassian Jira и переписать основной скрипт запуска на unit-файл

## Решение

Для выполнения заданий 1-3 написаны конфиги и  [Vagrantfile][Vagrantfile]. Для 4 задания - только конфиги.

1. Написаны 2 скрипта, оба запускаются как юниты для systemd:

- [loggenerator.sh](l/loggenerator.sh) - выбирает случайную цитату из файла [quotes.txt](1/quotes.txt) и генерирует лог-сообщение в файл /var/log/loggenerator.log

- [loganalizer.sh](1/loganalizer.sh) - раз в 30 секунд ищет ключевое слово в логфайле /var/log/loggenerator.log

2. [spawn-fcgi.service](2/spawn-fcgi.service) - unit-file сервиса.

3. [httpd@service](3/httpd@service) - файл шаблона сервиса. В [Vagrantfile](Vagrantfile) настроен запуск 3-х экземпляров httpd.

4. [jira.service](4/jira.service) - unit-file сервиса. К сожалению, не получилось передать переменные в строку запуска __ExecStart__.