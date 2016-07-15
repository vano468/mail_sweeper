# MailSweeper

## Instalation

* Add to Gemfile:
```
gem 'mail_sweeper', github: 'vad4msiu/mail_sweeper'
```
```
bundle install
```

* Copy migrations:
```
rake mail_sweeper:install:migrations
```
```
rake db:migrate
```

* Configure SES with SNS on url `http://<HOST>/mail_sweeper/sns`

## Usage

```
MailSweeper::EmailBlacklist.block!(email)           # temporary block a email
MailSweeper::EmailBlacklist.permanent_block!(email) # permanent block a email
MailSweeper::EmailBlacklist.unblock!(email)         # unblock a email
MailSweeper::EmailBlacklist.blocked?(email)         # check a email on block
```
