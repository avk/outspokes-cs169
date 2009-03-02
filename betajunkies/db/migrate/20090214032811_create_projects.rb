class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string :name
      t.string :link
      t.integer :user_id
      t.text :description
      t.text :summary

      t.timestamps
    end
  end

  def self.down
    drop_table :projects
  end
end
