# Вебинар 16. Автоматизация администрирования. Ansible

## Домашнее задание

первые шаги с ансибл

* реализовать плэйбук для разворачивания iptables из ДЗ14
* __*__ реализовать через роль

## Выполнение

### ansible role iptables_port_knocking

Role files tree:

```bash
.
└── iptables_port_knocking
    └── tasks
        ├── iptables_conf.yml
        ├── iptables_rules.yml
        └── main.yml

2 directories, 3 files

```

Variables:

* iptables_port_knocking_ssh_port - ssh server port

* iptables_port_knocking_knock_port_one - first knock port

* iptables_port_knocking_knock_port_two - second knock port

* iptables_port_knocking_knock_port_three - third knock port