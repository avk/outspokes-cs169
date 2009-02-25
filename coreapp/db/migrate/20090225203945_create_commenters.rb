class CreateCommenters < ActiveRecord::Migration
  def self.up
    create_table :commenters do |t|
      t.string :email

      t.timestamps
    end
  end

  def self.down
    drop_table :commenters
  end
end
