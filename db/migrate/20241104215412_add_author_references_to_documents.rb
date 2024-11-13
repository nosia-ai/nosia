class AddAuthorReferencesToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_reference :documents, :author, null: true, foreign_key: true
  end
end
