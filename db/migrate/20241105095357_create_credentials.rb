class CreateCredentials < ActiveRecord::Migration[8.0]
  def change
    create_table :credentials do |t|
      t.references :user, null: false, foreign_key: true
      t.string :provider
      t.text :uid
      t.jsonb :data

      t.timestamps
    end
  end
end
