# Smart Office

### Installation

(1) Install gems
```sh
$ bundle install
```

(2) Create DB
```sh
$ rake db:migrate:reset
```

(3) Run the following to generate application.yml

```sh
$ bundle exec figaro install
```

(4) Update an application.yml with the following environment variables:

```sh
telegram_bot_token: your_telegram_bot_token
telegram_authorized_chats: your_telegram_authorized_chats
web_cam_ip: your_web_cam_ip
```