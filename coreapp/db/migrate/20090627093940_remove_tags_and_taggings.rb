class RemoveTagsAndTaggings < ActiveRecord::Migration
  def self.up
    drop_table :tags
    drop_table :taggings
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
