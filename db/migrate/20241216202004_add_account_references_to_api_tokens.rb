class AddAccountReferencesToApiTokens < ActiveRecord::Migration[8.0]
  def up
    add_reference :api_tokens, :account, null: true, foreign_key: true

    ApiToken.all.each do |api_token|
      account = Account.find_by(owner: api_token.user)
      api_token.update(account:)
    end

    change_column_null :api_tokens, :account_id, false
  end

  def down
    remove_reference :api_tokens, :account
  end
end
