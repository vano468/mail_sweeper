class MailSweeper::SnsHandlerController < ApplicationController
  skip_before_action :verify_authenticity_token

  def sns
    result = MailSweeper::SnsNotificationService.perform(notification)

    if result
      render nothing: true
    else
      render nothing: true, status: :internal_server_error
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
