# Вебинар 4. Загрузка системы

## Домашнее задание

Работа с загрузчиком
1. Попасть в систему без пароля несколькими способами
2. Установить систему с LVM, после чего переименовать VG
3. Добавить модуль в initrd

4. __ (*)__ Сконфигурировать систему без отдельного раздела с /boot, а только с LVM
Репозиторий с пропатченым grub: https://yum.rumyantsev.com/centos/7/x86_64/
PV необходимо инициализировать с параметром --bootloaderareasize 1m


## Решение

1. Попасть в систему без пароля:

- вариант с rd.break

    - во время загрузки, редактируем меню grub
    - добавляем в конце строки с linux: __rd.break enforcing=0 console=tty0__
    - при загрузке в shell:
    ```
        $ mount -o remount,rw /sysroot
        $ chroot /sysroot
        $ passwd
        $ exit
        $ mount -o remount,ro /sysroot
        $ exit
    ```
    - при загрузке в систему:
    ```
        $ restorecon /etc/shadow
        $ setenforce 1
    ```

- вариант с systemd.debug-shell
    
    - во время загрузки, редактируем меню grub
    - добавляем в конце строки с linux: __systemd.debug-shell__
    - при загрузке системы переходим на 9 консоль __CTRL+ALT-F9__
    - меняем пароль root и перезагружаемся.

- вариант с init=/sysroot/bin/sh
    
    - во время загрузки, редактируем меню grub
    - добавляем в конце строки с linux: __init=/sysroot/bin/sh console=tty0__
    - при загрузке в shell:
    ```
        $ mount -o remount,rw /sysroot
        $ chroot /sysroot
        $ passwd
        $ exit
        $ reboot
    ```
    - во время загрузки, редактируем меню grub
    - добавляем в конце строки с linux: __enforcing=0__
    - при загрузке в shell:
    - при загрузке в систему:
    ```
        $ restorecon /etc/shadow
        $ setenforce 1
    ```

2. Установить систему с LVM, после чего переименовать VG

- переименовываем lvm группу:
```
    $ vgrename VolGroup00 NewGroup00
```

- монтируем текущие диски еще раз в новые папки:
```
    $ mkdir /run/sysroot
    $ mount /dev/mapper/NewGroup00-LogVol00 /run/sysroot
    $ mount /dev/vda2 /run/sysroot/boot
    $ mount -t proc proc /run/sysroot/proc
    $ mount -t sysfs sys /run/sysroot/sys
    $ mount -o bind /dev /run/sysroot/dev
```

- меняем конфиг /etc/default/grub и /etc/fstab:
```
    $ sed -i 's/VolGroup/NewGroup/g' /etc/default/grub
    $ sed -i 's/VolGroup/NewGroup/g' /etc/fstab
```

- создаем новый конфиг grub2:
```
    $ chroot /run/sysroot
    $ grub2-mkconfig -o /etc/grub2.cfg
    $ exit
    $ umount /run/sysroot/
    $ systemctl reboot
```

3. Добавить модуль в initrd

- создаем папку модуля:
```
    $ mkdir /usr/lib/dracut/modules.d/01test
```

- создаем файлы модуля [module-setup.sh](module-setup.sh), [test.sh](test.sh)
и помещаем их в созданную папку

- собираем образ initrd:
```
    $ dracut -f
```

4. __ (*)__ Сконфигурировать систему без отдельного раздела с /boot, а только с LVM
Репозиторий с пропатченым grub: https://yum.rumyantsev.com/centos/7/x86_64/
PV необходимо инициализировать с параметром --bootloaderareasize 1m

- для выполнения задания используется vagrant сборка centos 7

- копируем содержимое boot раздела:
```
    $ mkdir /opt/boot
    $ cp -ar /boot/* /opt/boot/
```

- создаем lvm для boot:
```
    $ umount /boot
    $ parted /dev/vda rm 1
    $ parted /dev/vda rm 2
    $ parted /dev/vda mkpart primary 0% 1076MB
    $ pvcreate /dev/vda1 --bootloaderareasize 1m
    $ vgcreate NewGroup01 /dev/vda1
    $ lvcreate -l 100%FREE -n BOOT NewGroup01
    $ mkfs.xfs /dev/mapper/NewGroup00-BOOT
```

- возвращаем файлы boot раздел обратно, меняем fstab:
```
    $ sed -i 's/^UUID.*/\/dev\/mapper\/NewGroup00-BOOT\t\/boot\t\t\txfs\tdefaults\t0 0/' /etc/fstab
    $ systemctl daemon-reload
    $ mount -a
    $ cp -ar /opt/boot/* /boot/
```

- удаляем оффициальные пакеты grub2, ставим пакеты с патчем:
```
    
    $ yum -y remove grub2*
    $ rpm -i https://yum.rumyantsev.com/centos/7/x86_64/grub2-common-2.02-0.65.el7.centos.2.noarch.rpm
    $ rpm -i https://yum.rumyantsev.com/centos/7/x86_64/grub2-tools-minimal-2.02-0.65.el7.centos.2.x86_64.rpm
    $ rpm -i https://yum.rumyantsev.com/centos/7/x86_64/grub2-tools-2.02-0.65.el7.centos.2.x86_64.rpm
    $ rpm -i https://yum.rumyantsev.com/centos/7/x86_64/grub2-tools-extra-2.02-0.65.el7.centos.2.x86_64.rpm
    $ rpm -i https://yum.rumyantsev.com/centos/7/x86_64/grub2-pc-modules-2.02-0.65.el7.centos.2.noarch.rpm
    $ rpm -i https://yum.rumyantsev.com/centos/7/x86_64/grub2-pc-2.02-0.65.el7.centos.2.x86_64.rpm
    $ rpm -i https://yum.rumyantsev.com/centos/7/x86_64/grub2-2.02-0.65.el7.centos.2.x86_64.rpm
```

- устанавливаем grub2:
```
    $ grub2-install /dev/vda
```
