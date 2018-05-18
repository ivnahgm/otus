# Вебинар 3. Файловые системы и LVM

## Домашнее задание

* Работа с LVM

* на имеющемся образе
/dev/mapper/VolGroup00-LogVol00 38G 738M 37G 2% /:

    * уменьшить том под / до 8G

    * выделить том под /home

    * выделить том под /var

    * /var - сделать в mirror

    * /home - сделать том для снэпшотов
    
    * прописать монтирование в fstab

* попробовать с разными опциями и разными файловыми системами ( на выбор)
    
    * сгенерить файлы в /home/

    * снять снэпшот
    
    * удалить часть файлов

    * восстановится со снэпшота

    * залоггировать работу можно с помощью утилиты screen

* __*__ на нашей куче дисков попробовать поставить btrfs/zfs - с кешем, снэпшотами - разметить здесь каталог /opt

## Решение

Для решения первой половины задания, выбран вариант с Live CD.

* Загружаемся с [SYSTEM RESCUE CD](http://www.system-rescue-cd.org/)

* Создаем и монтируем раздел для хранения промежуточного бэкапа файловой системы:

```bash
    $ parted /dev/vdb mklabel gpt && parted /dev/vdb mkpart primary 0% 100%
    $ mkfs.xfs /dev/vdb1
    $ mount /dev/vdb1 /mnt/backup
```bash

* С помощью комманды __xfsdump__ создаем бэкап текущей файловой системы:
```bash
    $ xfsdump -l 0 -L "" -f /mnt/backup/current_fs_backup.img -M "" /dev/mapper/VolGroup00-LogVol00
```

* Уменьшаем необходимый lvm том до 8G:
```bash
    $ lvreduce -L 8G /dev/mapper/VolGroup00-LogVol00
```

* Создаем заново файловую систему на диске, и монтируем ее:
```bash
    $ mkdir /mnt/current_system
    $ mkfs.xfs -f /dev/mapper/VolGroup00-LogVol00
    $ mount /dev/mapper/VolGroup00-LogVol00 /mnt/current_system
```

* Восстанавливаем файловую систему обратно:
```
    $ xfsrestore -f /mnt/backup/current_fs_backup.img /mnt/current_system/
```

* Добавляем физический диск к нашему lvm:
```
    $ pvcreate /dev/vdb1
    $ vgextend VolGroup00 /dev/vdb1
```

* Создаем отдельный том под /home:
```
    $ lvcreate -L 8G -n HOME VolGroup00
```

* Создаем отдельный логический зеркалируемый том под /var:
```
    $ lvcreate -L 7G -m1 -n VAR VolGroup00
```

* Создаем файловые системы на созданных томах:
```
    $ mkfs.ext4 /dev/mapper/VolGroup00-HOME
    $ mkfs.xfs /dev/mapper/VolGroup00-VAR
    $ mkdir -p /mnt/new_parts/home; mkdir -p /mnt/new_parts/var
    $ mount /dev/mapper/VolGroup00-HOME /mnt/new_parts/home
    $ mount /dev/mapper/VolGroup00-VAR /mnt/new_parts/var
```

* Копируем содержимое /home и /var на новые тома:
```
    $ cp -ar /mnt/current_system/home/* /mnt/new_parts/home/
    $ cp -ar /mnt/current_system/var/* /mnt/new_parts/var
```

* Удаляем содержимое старых /home, /var:
```
    $ rm -rf /mnt/current_system/home/*
    $ rm -rf /mnt/current_system/var/*
```

* Прописываем новые тома в /etc/fstab:
```
    $ echo "/dev/mapper/VolGroup00-HOME     /home   ext4    defaults,noatime    0   0" >> /mnt/current_system/etc/fstab
    $ echo "/dev/mapper/VolGroup00-VAR     /var   xfs    defaults,relatime    0   0" >> /mnt/current_system/etc/fstab
```

* Обновляем метки SELinux:
```
    $ touch /mnt/current_system/.autorelabel
```

* Перезагружаемся в систему


* Создаем snapshot volume для /home:
```
    $ lvcreate --size 200M --snapshot --name SNAPHOME /dev/mapper/VolGroup00-HOME
```

* Копируем в /home /var:
```
    $ cp -r /var /home/
```

* Восстанавливаем том:
```
    $ umount /home
    $ lvconvert --merge /dev/mapper/VolGroup00-SNAPHOME
    $ mount -a
```

* Установка zfs:
```
    $ yum -y update kernel \
    && yum -y install http://download.zfsonlinux.org/epel/zfs-release.el7_4.noarch.rpm \
    && yum -y install epel-release \
    && yum -y install kernel-devel zfs \
    && systemctl reboot
    $ dkms install zfs/0.7.9
    $ modprobe zfs
```

* Создаем zfs pool:
```
    $ zpool create zfsopt raidz1 /dev/vd{c,d,e,f} -m /opt
```

* Добавляем cache диск:
```
    $ zpool add zfsopt cache /dev/vdg
```

* Создаем snapshot:
```
    $ zfs snapshot zfsopt@now
```

* Восстанавливаемся:
```
    $ zfs rollback zfsopt@now
```

* Удаляем snapshot:
```
    $ zfs destroy zfsopt@now
```

* Лог работы в файле [screenlog.0](screenlog.0)
