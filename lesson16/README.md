# Вебинар 17. Пользователи и группы. Авторизация и аутентификация

## Домашнее задание

PAM

1. Запретить всем пользователям, кроме группы admin логин в выходные и праздничные дни

2. Дать конкретному пользователю права рута

## Выполнение

1. Запретить всем пользователям, кроме группы admin логин в выходные и праздничные дни

Для выполнения задания была написана ansible роль access_via_pam_script:

```
access_via_pam_script
├── handlers
│   └── main.yml
├── tasks
│   ├── install_packages.yml
│   ├── main.yml
│   ├── set_pam.yml
│   ├── set_sshd.yml
│   └── set_users.yml
└── templates
    └── etc
        └── pam-script.d
            └── pam_script_acct.j2

5 directories, 7 files

```

Переменные роли:

* access_via_pam_script_always_allow_group - группа, доступ для которой открыт всегда

* access_via_pam_script_always_allow_user - пользователь,для добавления в привилегированную группу

* access_via_pam_script_celebrations - список праздничных дней

* access_via_pam_script_simple_group - шруппа "простого" пользователя (для целей тестирования)

* access_via_pam_script_simple_user - имя "простого" пользователя (для целей тестирования)

В группу **admin** добавляется пользователь **vagrant**. Дополнительно создается пользователь **otus**,
пароль для которого создается в процессе настройки стенда.

Пример вывода пароля для пользователя otus:

```
TASK [access_via_pam_script : debug] *******************************************
ok: [pamotus] => {
    "msg": "Password for otus is 10xp"
}
```

2. Дать конкретному пользователю права рута

Для выполнения задания была написана ansible роль auth_via_pam_cap:

```
auth_via_pam_cap
├── tasks
│   ├── main.yml
│   └── set_pam_cap.yml
└── templates
    └── etc
        └── security
            └── capability.conf.j2

4 directories, 3 files
```

Переменные роли:

* auth_via_pam_cap_user - пользователь, которому добавляется capability CAP_SYS_ADMIN

CAP_SYS_ADMIN добавляется для пользователя **vagrant** во время **login**(локальный вход, не ssh).