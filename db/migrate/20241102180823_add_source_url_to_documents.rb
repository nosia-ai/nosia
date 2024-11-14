class AddSourceUrlToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :documents, :source_url, :string
  end
end
