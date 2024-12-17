class AddAccountReferencesToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_reference :documents, :account, null: true, foreign_key: true
  end
end
