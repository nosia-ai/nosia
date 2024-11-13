class AddUidAndContentHashToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :documents, :uid, :string
    add_column :documents, :content_hash, :string
  end
end
