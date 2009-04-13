class AddAgreeAndDisagreeCountsToFeedbacks < ActiveRecord::Migration
  def self.up
    add_column :feedbacks, :agreed, :integer, :default => 0
    add_column :feedbacks, :disagreed, :integer, :default => 0
  end

  def self.down
    remove_column :feedbacks, :disagreed
    remove_column :feedbacks, :agreed
  end
end
