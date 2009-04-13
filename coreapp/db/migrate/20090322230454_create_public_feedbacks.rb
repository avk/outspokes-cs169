class CreatePublicFeedbacks < ActiveRecord::Migration
  def self.up
    add_column :feedbacks, :type, :string
    add_column :feedbacks, :name, :string
  end

  def self.down
    remove_column :feedbacks, :name
    remove_column :feedbacks, :type
  end
end
