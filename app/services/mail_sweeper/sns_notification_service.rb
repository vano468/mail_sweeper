module MailSweeper
  class SnsNotificationService
    SUBSCRIPTION_CONFIRMATION_TYPE = 'SubscriptionConfirmation'
    NOTIFICATION_TYPE              = 'Notification'

    NOTIFICATION_TYPES = [
      BOUNCE_TYPE    = 'Bounce',
      COMPLAINT_TYPE = 'Complaint'
    ]

    BOUNCE_TYPES = [
      BOUNCE_TYPE_PERMANENT    = 'Permanent',
      BOUNCE_TYPE_UNDETERMINED = 'Undetermined',
      BOUNCE_TYPE_TRANSIENT    = 'Transient'
    ]

    class << self
      def perform(*args)
        new(*args).perform
      end
    end

    def initialize(notification)
      @notification = notification
    end

    def perform
      case type
      when SUBSCRIPTION_CONFIRMATION_TYPE
        confirm_subscription
      when NOTIFICATION_TYPE
        process_notification
      else
        raise StandardError, "Undefined type '#{ type.inspect }'"
      end
    end

    private

    attr_reader :notification

    def confirm_subscription
      SnsSubscriptionConfirmationService.perform(subscribe_url)
    end

    def process_notification
      case notification_type
      when BOUNCE_TYPE
        process_bounce_notification
      when COMPLAINT_TYPE
        process_complaint_notification
      end
    end

    def process_bounce_notification
      case bounce_type
      when BOUNCE_TYPE_TRANSIENT, BOUNCE_TYPE_UNDETERMINED
        block_recipients
      when BOUNCE_TYPE_PERMANENT
        block_recipients_permanently
      else
        raise StandardError, "Undefined bounce type '#{ bounce_type.inspect }'"
      end
    end

    def process_complaint_notification
      block_recipients_permanently
    end

    def block_recipients_permanently
      recipients.each do |recipient|
        MailSweeper::EmailBlacklist.permanent_block!(recipient)
      end
    end

    def block_recipients
      recipients.each do |recipient|
        MailSweeper::EmailBlacklist.block!(recipient)
      end
    end

    def type
      @type ||= notification['Type']
    end

    def message
      @message ||= JSON.parse(notification['Message'])
    end

    def recipients
      @recipients ||= message['mail']['destination']
    end

    def bounce_type
      @bounce_type ||= message['bounce']['bounceType']
    end

    def subscribe_url
      @subscribe_url ||= notification['SubscribeURL']
    end

    def notification_type
      @notification_type ||= message['notificationType']
    end
  end
end
