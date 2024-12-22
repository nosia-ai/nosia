class FixChunkableInChunks < ActiveRecord::Migration[8.0]
  def up
    remove_foreign_key :chunks, :documents
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "This migration cannot be reverted."
  end
end
