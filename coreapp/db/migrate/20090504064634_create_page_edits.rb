class CreatePageEdits < ActiveRecord::Migration
  def self.up
    add_column :feedbacks, :changeset, :text
  end

  def self.down
    remove_column :feedbacks, :changeset
  end
end
