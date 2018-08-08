# Вебинар 7. Управление процессами

## Домашнее задание

работаем с процессами

Задания на выбор

1. написать свою реализацию ps ax используя анализ /proc
- Результат ДЗ - рабочий скрипт который можно запустить

2. написать свою реализацию lsof
- Результат ДЗ - рабочий скрипт который можно запустить

3. дописать обработчики сигналов в прилагаемом скрипте, оттестировать, приложить сам скрипт, инструкции по использованию
- Результат ДЗ - рабочий скрипт который можно запустить + инструкция по использованию и лог консоли

4. реализовать 2 конкурирующих процесса по IO. пробовать запустить с разными ionice
- Результат ДЗ - скрипт запускающий 2 процесса с разными ionice, замеряющий время выполнения и лог консоли

5. реализовать 2 конкурирующих процесса по CPU. пробовать запустить с разными nice
- Результат ДЗ - скрипт запускающий 2 процесса с разными nice и замеряющий время выполнения и лог консоли

## Решение

1. **ps ax**

Скрипт [psax.sh](psax.sh) реализует вывод комманды __ps ax__:

- значение __PID__ (функция get_pid () ) берется из имени папки процесса в /proc

- значение __TTY__ (функция get_tty () ) берется из пути символьной ссылки /proc/[PROCESS_PID]/fd/0, если она доступна или указывает на устройство терминала

- значение __STAT__ (функция get_stat () )

  - основной статус берется из строки ^State файла /proc/[PROCESS_PID]/status
  - значение "high/low-priority" берется из 18 значения файла /proc/[PROCESS_PID]/stat
  - значение "has pages locked into memory" берется из строки ^VmLck файла /proc/PROCESS_PID/status
  - значение "is a session leader" берется из 6 значения файла /proc/[PROCESS_PID]/stat
  - значение "is multi-threaded" берется из 20 значения файла /proc/[PROCESS_PID]/stat
  - значение "is in the foreground process group" берется из 8 значения файла /proc/[PROCESS_PID]/stat

2. **lsof**

Скрипт [lsof.sh](lsof.sh) реализует вывод комманды __lsof__:

- значение __COMMAND__ (функция get_command() ) берется из файла /proc/[PROCESS_PID]/comm

- значение __PID__ берется из имени папки в /proc

- значение __TID__ не реализовано (обработку папок в /proc/[PROCESS_PID]/task/ уже не осилил морально)

- значение __USER__ берется из значения владельца папки /proc/[PROCESS_PID]

- значение __FD__:

  - для /proc/[PROCESS_PID]/cwd - "cwd"
  - для /proc/[PROCESS_PID]/root - "rtd"
  - для /proc/[PROCESS_PID]/exe - "txt"
  - для файлов в папке /proc/[PROCESS_PID]/map_files/ - "mem"
  - для дескрипторов в /proc/[PROCESS_PID]/fd/ - имя соответствующей символической сылки + значение
  режима доступа, флаг берется из файла /proc/[PROCESS_PID]/fdinfo/[FD] из значения последнего байта в строке __^flags:__

- значение __TYPE__:

  - для /proc/[PROCESS_PID]/cwd - "DIR"
  - для /proc/[PROCESS_PID]/root - "DIR"
  - для /proc/[PROCESS_PID]/exe - "REG"
  - для файлов в папке /proc/[PROCESS_PID]/map_files/ - "REG". **Не реализовано:** тип "DEL"
  - для дескрипторов в /proc/[PROCESS_PID]/fd/ - для папок "DIR", для character special file "CHR", для файлов "REG",
юникс сокетов "unix", для сетевых сокетов "IPv4" или "IPv6", для anon_inode "a_inode", для pipe "FIFO", для остального "?"

- значение __DEVICE__:

  - для cwd, root и exe - значение берется из вывода команды ```stat -c %D```
  - для файлов в папке /proc/[PROCESS_PID]/map_files/ - из файла /proc/[PROCESS_PID]/maps
  - для дескрипторов из файла /proc/[PROCESS_PID]/mountinfo, для юникс сокетов из /proc/[PROCESS_PID]/net/unix

3. Обработчики сигналов в скрипте **myfork.py**

В скрипт [myfork.py](myfork.py) добавлены обработчики сигналов SIGCHLD, SIGTERM, SIGINT

4. **difionice.sh**

Скрипт запускает два процесса ``` dd if=/dev/urandom of=somefile ```

Запуск скрипта с 5 параметрами:

* **--count** - параметр для dd, сколько циклов записи по 10M совершить. Фактически определяет размер конечного файла (count*10M)  

* **--class1** - значение class (от 0 до 3) для первого процесса (по умолчанию 0)

* **--class2** - значение class (от 0 до 3) для второго процесса (по умолчанию 0)

* **--level1** - значение level (от 0 до 7) для первого процесса (по умолчанию 7)

* **--level2** - значение level (от 0 до 7) для второго процесса (по умолчанию 7)

3. 4 и 5 значения задают параметры class (от 0 до 3) и level (от 0 до 7) для второго процесса

Пример запуска:
```
  $ bash difionice.sh --count 50 --class1 2 --class2 2 --level1 1 --level2 5
```

5. **difnice.sh**

Скрипт запускает два процесса ``` dd if=/dev/urandom of=/dev/null bs=10M count=$COUNT ```

Запуск скрипта с 3 позиционными параметрами:

1. COUNT - параметр для dd, сколько циклов записи по 10M совершить. Фактически определяет размер конечного файла (count*10M)  

2. 2 и 3 значения задают параметр nice для 1 и 2 процессов соотвественно.

Пример запуска:
```
  $ bash difnice.sh 10 10 -2
```

Все скрипты можно проверить на стенде. Файл [Vagrantfile](Vagrantfile) прилагается.