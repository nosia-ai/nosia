class CreateAccountUsers < ActiveRecord::Migration[8.0]
  def up
    create_table :account_users do |t|
      t.references :account, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    Account.all.each do |account|
      account.account_users.create(user: account.owner)
    end
  end

  def down
    drop_table :account_users
  end
end
