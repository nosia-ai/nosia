class AddAccountReferencesToApiTokens < ActiveRecord::Migration[8.0]
  def up
    add_reference :api_tokens, :account, null: true, foreign_key: true

    account = Account.find_by(name: "First account")
    ApiToken.update_all(account_id: account.id)

    change_column_null :api_tokens, :account_id, false
  end

  def down
    remove_reference :api_tokens, :account
  end
end
