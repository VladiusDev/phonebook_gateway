### ОПИСАНИЕ
Загружает данные по сотрудникам из MySQL и помещает в Sqlite, запускает http сервер и отдает по API данные. Данные загружаются с периодичностью 24 часа.

### НАСТРОЙКА КОНФИГА
В корне проекта добавить config.yaml и указать параметры подключения:

IP сервера и Port на котором будет стартовать веб сервер с API
```yaml
http_server:
  ip: "0.0.0.0"
  port: 8080
```

Подключения к MySQL 
```yaml
my_sql_server:
  host: "your host"
  port: 3306
  user: "user"
  password: "user password"
  database: "database name 
```

### ИСПОЛЬЗОВАНИЕ API
Для использования API отправляем GET запрос на url [your ip]:[your port]/employees

