class CreateAccounts < ActiveRecord::Migration[8.0]
  def up
    create_table :accounts do |t|
      t.string :name
      t.belongs_to :owner, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    User.all.each do |user|
      Account.create(name: user.email, owner: user)
    end
  end

  def down
    drop_table :accounts
  end
end
