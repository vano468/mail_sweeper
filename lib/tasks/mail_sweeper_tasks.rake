namespace :mail_sweeper do
  desc "Sweep email blacklist"
  task sweep: :environment do
    items = MailSweeper::EmailBlacklist.only_for_unblock
    puts "For unblock #{ items.count } emails"
    items.find_each do |item|
      puts "Unblock #{ item.email }"
      item.unblock!
    end
  end
end
