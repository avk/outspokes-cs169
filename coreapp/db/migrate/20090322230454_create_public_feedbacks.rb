class CreatePublicFeedbacks < ActiveRecord::Migration
  def self.up
    rename_table :feedbacks, :abstract_feedbacks
    add_column :abstract_feedbacks, :type, :string
    add_column :abstract_feedbacks, :name, :string
  end

  def self.down
    rename_table :abstract_feedbacks, :feedbacks
    remove_column :feedbacks, :name
    remove_column :feedbacks, :type
  end
end
