# Инфраструктура как код

[![hexlet-check](https://github.com/a-shein/devops-for-developers-project-77/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/a-shein/devops-for-developers-project-77/actions)

Автоматизация создания инфраструктуры проекта через Terraform и Ansible

Учебный проект Хекслета: https://ru.hexlet.io/programs/devops-for-developers
Как это должно работать: https://asciinema.org/a/aeg7afREm5TJHn9PT0S465lEa

## Стек

- Terraform (провайдеры `kreuzwerker/docker`, `hashicorp/tls`)
- Ansible + Ansible Vault (генерация секретов для Terraform)
- Docker, MinIO (удалённый S3-стейт)

Облако не используется: серверы — контейнеры Docker на локальной машине, стейт хранится в локальном MinIO (S3-совместимое хранилище, замена Yandex Object Storage).

## Инфраструктура

- 2 веб-сервера — `project77-app1`, `project77-app2` (контейнеры `docker:dind`, у каждого свой Docker-демон; приложение Redmine на них деплоит Ansible)
- балансировщик нагрузки (nginx) с HTTPS и самоподписанным сертификатом — `project77-lb`
- база данных PostgreSQL — `project77-db`

## Установка

```bash
git clone https://github.com/a-shein/devops-for-developers-project-77.git
cd devops-for-developers-project-77
```

Нужны: Docker, Ansible, Terraform. Файл `.vault_pass` с паролем Vault лежит в корне (не в репозитории).
Для Terraform backend задайте ключи MinIO:

```bash
export AWS_ACCESS_KEY_ID=tfstate
export AWS_SECRET_ACCESS_KEY=<секрет>
```

## Использование

```bash
make backend   # поднять MinIO для стейта (один раз)
make init      # сгенерировать secrets.auto.tfvars из vault и terraform init
make plan      # посмотреть изменения
make apply     # создать инфраструктуру
make prepare   # инвентори из Terraform, коллекции Ansible, образ приложения на серверах
make deploy    # запустить приложение на серверах (ansible/playbook.yml, --tags deploy)
make monitoring # агент Datadog на серверах (http_check приложения)
make destroy   # удалить инфраструктуру
```

Порядок: `make backend`, `make init`, `make apply`, `make prepare`, `make deploy`. Пароль БД берётся из зашифрованного `ansible/vault.yml`.

Результат: `https://localhost:8443` (балансировщик, сертификат самоподписанный), прямые адреса серверов — `http://localhost:8081`, `http://localhost:8082`. Первый запуск Redmine занимает около минуты.

## Домен

Приложение доступно по домену: **https://project77.test:8443**

Реальный домен не регистрировался (платно), используется зарезервированная зона `project77.test`. Terraform поднимает локальный DNS-сервер (CoreDNS, `terraform/dns.tf`) с A-записью домена на балансировщик, а сертификат балансировщика выписан на этот домен. `make check-domain` проверяет запись через `dig` и HTTPS-запрос с проверкой сертификата.

Чтобы открыть домен в браузере, добавьте его в hosts: `echo "127.0.0.1 project77.test" | sudo tee -a /etc/hosts`

## Мониторинг

Агент Datadog ставится на серверы через Ansible (`make monitoring`) и каждые 15 секунд делает HTTP-запрос к приложению (`http_check`). Terraform (`terraform/monitoring.tf`) создаёт в Datadog по монитору `http.can_connect` на каждый сервер. Ключи `vault_dd_api_key` и `vault_dd_app_key` хранятся в `ansible/vault.yml`, сайт Datadog задаётся `dd_site` (`ansible/group_vars/webservers.yml`) и `dd_api_url` (Terraform).

Внешний мониторинг доступности (Upmon) не подключён: приложение работает локально и недоступно из интернета.

Секреты: `make vault-edit` правит `ansible/vault.yml`; `ansible/secrets.yml` рендерит `terraform/secrets.auto.tfvars` (файл в `.gitignore`).

---

<details>
<summary>Автоматические тесты Хекслета</summary>

Тесты запускаются на каждый коммит. За запуск отвечает файл `.github/workflows/hexlet-check.yml` — не удаляйте и не переименовывайте ни его, ни репозиторий.

</details>

## О Хекслете

[Хекслет](https://ru.hexlet.io/) — школа программирования: авторские программы обучения с практикой, поддержкой наставников и реальными проектами, которые остаются в резюме. Этот репозиторий — один из таких проектов.
