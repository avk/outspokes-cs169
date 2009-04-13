class CreateOpinions < ActiveRecord::Migration
  def self.up
    if Feedback.column_names.include?("agreed") and Feedback.column_names.include?("disagreed")
      remove_column :feedbacks, :agreed
      remove_column :feedbacks, :disagreed
    end
    create_table :opinions do |t|
      t.references :feedback
      t.references :commenter
      t.boolean :agreed
      t.timestamps
    end
  end

  def self.down
    drop_table :opinions
  end
end
