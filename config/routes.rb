MailSweeper::Engine.routes.draw do
  controller :sns_handler do
    post :sns
  end
end
