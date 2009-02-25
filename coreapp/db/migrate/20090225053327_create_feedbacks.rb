class CreateFeedbacks < ActiveRecord::Migration
  def self.up
    create_table :feedbacks do |t|
      t.integer :page_id, :null => false
      t.integer :commenter_id, :null => false
      t.text :content, :limit => 500

      t.timestamps
    end
  end

  def self.down
    drop_table :feedbacks
  end
end
