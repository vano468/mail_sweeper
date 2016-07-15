class CreateMailSweeperEmailBlacklists < ActiveRecord::Migration
  def change
    create_table :mail_sweeper_email_blacklists do |t|
      t.string :email, null: false
      t.integer :block_counter, null: false, default: 0
      t.datetime :blocked_until
      t.boolean :permanently_blocked, default: false

      t.timestamps null: false
    end

    add_index :mail_sweeper_email_blacklists, :email, unique: true
  end
end
