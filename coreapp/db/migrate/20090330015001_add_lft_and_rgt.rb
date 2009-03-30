class AddLftAndRgt < ActiveRecord::Migration
  def self.up
    add_column :feedbacks, :lft, :integer
    add_column :feedbacks, :rgt, :integer
    
    # make all the existing feedbacks top-level (i.e. not children of any other feedbacks)
    execute "UPDATE feedbacks SET lft = 1, rgt = 2 WHERE parent_id IS NULL;"
  end

  def self.down
    remove_column :feedbacks, :lft
    remove_column :feedbacks, :rgt
  end
end
