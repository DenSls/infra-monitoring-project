# infra-monitoring-project

Домашняя работа по программной инженерии.

## SSH и SCP

### Создание SSH-ключа

Создайте пару ключей Ed25519 и задайте парольную фразу по запросу:

~~~bash
ssh-keygen -t ed25519 -C "infra-monitoring-project"
~~~

Закрытый ключ храните на рабочей машине в ~/.ssh/id_ed25519. Не копируйте его на сервер.

### Копирование публичного ключа

Укажите имя пользователя и адрес сервера, затем установите только публичный ключ:

~~~bash
DEPLOY_USER=deploy
DEPLOY_HOST=server.example.com

ssh-copy-id -i ~/.ssh/id_ed25519.pub "$DEPLOY_USER@$DEPLOY_HOST"
~~~

При первом подключении сверьте отпечаток ключа сервера по доверенному каналу, прежде чем принимать его.

### Передача архива и запуск проекта

После коммита изменений запустите команду из корня проекта. git archive передаст файлы последнего коммита без каталога .git. Незакоммиченные изменения и неотслеживаемые файлы в архив не попадут:

~~~bash
git archive --format=tar HEAD |
  ssh "$DEPLOY_USER@$DEPLOY_HOST" \
    'mkdir -p ~/infra-monitoring-project &&
     tar -xf - -C ~/infra-monitoring-project &&
     cd ~/infra-monitoring-project &&
     docker-compose up -d'
~~~
