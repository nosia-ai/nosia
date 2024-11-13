class AddUserReferencesToChats < ActiveRecord::Migration[8.1]
  def change
    add_reference :chats, :user, null: false, foreign_key: true
  end
end
