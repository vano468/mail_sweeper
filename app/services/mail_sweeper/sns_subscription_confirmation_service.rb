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
      response = HTTParty.get(callback_url)
      response.code.to_i < 400
    end

    private

    attr_reader :callback_url
  end
end
