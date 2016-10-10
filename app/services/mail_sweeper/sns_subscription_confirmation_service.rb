module MailSweeper
  class SnsSubscriptionConfirmationService
    class << self
      def perform(callback_url)
        new(callback_url).perform
      end
    end

    def initialize(callback_url)
      @callback_url = callback_url
    end

    def perform
      if callback_url
        response = HTTParty.get(callback_url)
        response.code.to_i < 400
      else
        true
      end
    end

    private

    attr_reader :callback_url
  end
end
