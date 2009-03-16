class AddTargetToFeedbacks < ActiveRecord::Migration
  def self.up
    add_column :feedbacks, :target, :string
  end

  def self.down
    remove_column :feedbacks, :target
  end
end
