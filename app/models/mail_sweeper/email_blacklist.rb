module MailSweeper
  class EmailBlacklist < ActiveRecord::Base
    BLOCK_MODIFIER = 4.weeks

    validates :email, presence: true, uniqueness: true
    validates :block_counter, presence: true, numericality: { greater_than: 0 }
    validate :check_consistency_blocked_and_blocked_until

    scope :with_email, -> (email) { where(email: email) }
    scope :only_blocked, -> { where(blocked: true) }
    scope :only_for_unblock, -> {
      conditions = [
        arel_table[:blocked].eq(true),
        arel_table[:blocked_until].lteq(Time.now)
      ]

      where(conditions.reduce(&:and))
    }

    class << self
      def block!(email)
        item = EmailBlacklist.find_or_initialize_by(email: email)
        item.block!

        item
      end

      def permanent_block!(email)
        item = EmailBlacklist.find_or_initialize_by(email: email)
        item.permanet_block!

        item
      end

      def unblock!(email)
        item = EmailBlacklist.find_by!(email: email)
        item.unblock!

        item
      end

      def blocked?(email)
        EmailBlacklist.with_email(email).only_blocked.exists?
      end
    end

    def block!
      self.block_counter += 1
      self.blocked = true
      self.blocked_until = calculate_unblock_date

      save!
    end

    def permanet_block!
      self.block_counter += 1
      self.blocked = true
      self.blocked_until = nil

      save!
    end

    def unblock!
      update!(blocked_until: nil, blocked: false)
    end

    private

    def calculate_unblock_date
      Time.now + block_counter * BLOCK_MODIFIER
    end

    def check_consistency_blocked_and_blocked_until
      if blocked_until.present? && blocked == false
        errors.add :blocked, "can not be false if blocked_until is present"
      end
    end
  end
end
