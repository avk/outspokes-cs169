class AddPagesAndCommentersToFeedback < ActiveRecord::Migration
  def self.up
    add_column :feedbacks, :commenter_id, :integer
    add_column :feedbacks, :page_id, :integer
  end

  def self.down
    remove_column :feedbacks, :commenter_id
    remove_column :feedbacks, :page_id
  end
end
