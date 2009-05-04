class AddPrivateToFeedbacks < ActiveRecord::Migration
  def self.up
    add_column :feedbacks, :private, :boolean, :default => false
  end

  def self.down
    remove_column :feedbacks, :private
  end
end
