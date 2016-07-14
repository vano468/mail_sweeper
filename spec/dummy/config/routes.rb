Rails.application.routes.draw do

  mount MailSweeper::Engine => "/mail_sweeper"
end
