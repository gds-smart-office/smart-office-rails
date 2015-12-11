# Smart Office

## Installation

(1) Install gems
```sh
$ bundle install
```

(2) Create DB
```sh
$ rake db:migrate:reset
```

(3) Run the following to generate the application.yml

```sh
$ bundle exec figaro install
```

(4) Update the application.yml with the following environment variables:

```sh
telegram_bot_token: [your_telegram_bot_token]
pong_ip: [your_pong_ip]
recep_ip: [your_recep_ip]
restart_cooldown: [your_restart_cooldown]
password: [your_password]
```

(5) Run Telegram bot thread using Rake task
```sh
$ rake telegram_bot:run
```

(6) Run Rails server
```sh
$ rails s
```

## API

### Pong
|              |                                          |
|--------------|-------------------------------------------|
| POST         | http://\<ip_address\>/api/v1/telegram/pong  |
| Header*      | Authorization: Token token=\<your_token\>   |
| Params:      |                                           |
| chat_id*     | \<your_telegram_chat_id\>                   |
| caption      | \<your_caption\>                            |
| Responses:   |                                           |
| Success      | {status: “success”}                       |
| Error        | {status: “error”}                         |
| Unauthorized | {status: “unauthorized”}                  |

### Recep
|              |                                          |
|--------------|-------------------------------------------|
| POST         | http://\<ip_address\>/api/v1/telegram/recep  |
| Header*      | Authorization: Token token=\<your_token\>   |
| Params:      |                                           |
| chat_id*     | \<your_telegram_chat_id\>                   |
| caption      | \<your_caption\>                            |
| following    | true/false                                |
| Responses:   |                                           |
| Success      | {status: “success”}                       |
| Error        | {status: “error”}                         |
| Unauthorized | {status: “unauthorized”}                  |

