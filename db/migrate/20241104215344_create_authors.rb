class CreateAuthors < ActiveRecord::Migration[8.0]
  def change
    create_table :authors do |t|
      t.string :name
      t.string :description
      t.string :url
      t.string :image_url

      t.timestamps
    end
  end
end
