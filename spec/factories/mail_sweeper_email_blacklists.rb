FactoryGirl.define do
  factory :email_blacklist, class: 'MailSweeper::EmailBlacklist' do
    email { |n| "email_#{n}@example.com" }

    beforex
  end
end
