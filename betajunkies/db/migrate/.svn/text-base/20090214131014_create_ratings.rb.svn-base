class CreateRatings < ActiveRecord::Migration
  def self.up
    create_table :ratings do |t|
	t.column :project_id, :integer
	t.column :comment_id, :integer
	t.column :user_id, :integer
	t.column :value, :float
	t.column :created_at, :datetime
      t.timestamps
    end
  end

  def self.down
    drop_table :ratings
  end
end
