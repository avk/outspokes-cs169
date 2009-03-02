class AddParentToComment < ActiveRecord::Migration
  def self.up
    add_column :comments, :parent, :integer
  end

  def self.down
    remove_column :comments, :parent
  end
end
