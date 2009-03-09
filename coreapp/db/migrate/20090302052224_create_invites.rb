class CreateInvites < ActiveRecord::Migration
  def self.up
    create_table :invites do |t|
      t.string :url_token
      t.references :page, :null => false
      t.references :commenter, :null => false
      t.timestamps
    end
    
    add_index :invites, :url_token
  end

  def self.down
    drop_table :invites
  end
end
