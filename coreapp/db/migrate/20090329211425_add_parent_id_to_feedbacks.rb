class AddParentIdToFeedbacks < ActiveRecord::Migration
  def self.up
    add_column :feedbacks, :parent_id, :integer
  end

  def self.down
    remove_column :feedbacks, :parent_id
  end
end
