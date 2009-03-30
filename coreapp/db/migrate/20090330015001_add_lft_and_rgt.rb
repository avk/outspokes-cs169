class AddLftAndRgt < ActiveRecord::Migration
  def self.up
	add_column :feedbacks, :lft, :integer
	add_column :feedbacks, :rgt, :integer
  end

  def self.down
    remove_column :feedbacks, :lft
	remove_column :feedbacks, :rgt
  end
end
