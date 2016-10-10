class MailSweeper::SnsHandlerController < ActionController::Base
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token

  def sns
    Logger.new("#{Rails.root}/log/ses.log").info notification
    result = MailSweeper::SnsNotificationService.perform(notification)

    if result
      head :ok
    else
      head :internal_server_error
    end
  end

  private

  def notification
    @notification ||= JSON.parse(body)
  end

  def body
    @body ||= request.body.read
  end
end
