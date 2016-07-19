module MailSweeper
  class EmailBlacklist < ActiveRecord::Base
    START_BLOCK_MODIFIER = 1.week
    BLOCK_MODIFIER       = 4.weeks

    validates :email, presence: true, uniqueness: true
    validates :block_counter, presence: true, numericality: { greater_than: 0 }

    scope :with_email, -> (email) { where(email: email) }
    scope :only_blocked, -> {
      conditions = [
        arel_table[:permanently_blocked].eq(true),
        arel_table[:blocked_until].gt(Time.now)
      ]

      where(conditions.reduce(&:or))
    }
    scope :only_for_unblock, -> {
      conditions = [
        arel_table[:permanently_blocked].eq(false),
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
      self.permanently_blocked = false
      self.blocked_until = calculate_unblock_date

      save!
    end

    def permanet_block!
      self.block_counter += 1
      self.permanently_blocked = true
      self.blocked_until = nil

      save!
    end

    def unblock!
      update!(blocked_until: nil, permanently_blocked: false)
    end

    private

    def calculate_unblock_date
      distance = if block_counter == 1
        START_BLOCK_MODIFIER
      else
        BLOCK_MODIFIER ** (block_counter - 1)
      end

      Time.now + distance
    end
  end
end
