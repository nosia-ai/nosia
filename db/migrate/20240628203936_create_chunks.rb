class CreateChunks < ActiveRecord::Migration[8.0]
  def change
    create_table :chunks do |t|
      t.belongs_to :document, null: false, foreign_key: true
      t.text :content
      t.vector :embedding, limit: 768

      t.timestamps
    end
  end
end
