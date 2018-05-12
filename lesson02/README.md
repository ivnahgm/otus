# Вебинар 2. Дисковая подсистема 

## Домашнее задание

* работа с mdadm.
* добавить в Vagrantfile еще дисков
* сломать/починить raid
* собрать R0/R5/R10 на выбор 
* прописать собранный рейд в конф, чтобы рейд собирался при загрузке
* создать GPT раздел и 5 партиций
* в качестве проверки принимаются - измененный Vagrantfile, скрипт для создания рейда, конф для автосборки рейда при загрузке
* __\* доп. задание__ - Vagrantfile, который сразу собирает систему с подключенным рейдом

## Решение

* приложен файл [Vagrantfile](Vagrantfile)
* в системе 6 дополнительных дисков
* собирается RAID5
* все действия прописаны в Vagrantfile:
```ruby
                 override.vm.provision "shell", inline: <<-SHELL
                        mdadm --zero-superblock /dev/sd{b,c,d,e,f,g}
                        mdadm /dev/md0 --create -l 5 -n 6 /dev/sd{b,c,d,e,f,g}
                        mdadm --detail --scan --verbose > /etc/mdadm.conf
                        parted -s /dev/md0 mklabel gpt
                        parted /dev/md0 mkpart primary ext4 0% 20%
                        parted /dev/md0 mkpart primary ext4 20% 40%
                        parted /dev/md0 mkpart primary ext4 40% 60%
                        parted /dev/md0 mkpart primary ext4 60% 80%
                        parted /dev/md0 mkpart primary ext4 80% 100%
                  SHELL
```  
