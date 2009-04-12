class AddPublicToFeedback < ActiveRecord::Migration
  def self.up
    add_column :feedbacks, :public, :boolean
  end

  def self.down
    remove_column :feedbacks, :public
  end
end
