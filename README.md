### ОПИСАНИЕ
Загружает данные по сотрудникам из MySQL и помещает в Sqlite, запускает http сервер и отдает по API данные. Данные загружаются с периодичностью 24 часа.

### НАСТРОЙКА КОНФИГА
В корне проекта добавить config.yaml и указать параметры подключения:

HTTP SERVER API
```yaml
http_server:
  ip: "0.0.0.0"
  port: 8080
```
MySQL 
```yaml
my_sql_server:
  host: "your host"
  port: 3306
  user: "user"
  password: "user password"
  database: "database name 
```
SENTRY 
```yaml
sentry:
  dsn: "your dsn"
```

### ИСПОЛЬЗОВАНИЕ API
Для использования API отправляем GET запрос на url [your ip]:[your port]/employees

