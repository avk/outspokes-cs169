class CreateAccounts < ActiveRecord::Migration
  def self.up
    
    change_column :commenters, :email,                  :string, :limit => 100
    
 	add_column :commenters, :name,                      :string, :limit => 100, :default => '', :null => true
    add_column :commenters, :crypted_password,          :string, :limit => 40
    add_column :commenters, :salt,                      :string, :limit => 40
    add_column :commenters, :remember_token,            :string, :limit => 40
    add_column :commenters, :remember_token_expires_at, :datetime
    add_column :commenters, :type,                      :string

    add_index :commenters, :email, :unique => true
  end

  def self.down

    change_column :commenters, :email,                  :string
    
 	remove_column :commenters, :name
    remove_column :commenters, :crypted_password
    remove_column :commenters, :salt
    remove_column :commenters, :remember_token
    remove_column :commenters, :remember_token_expires_at
    remove_column :commenters, :type

    remove_index :commenters, :email
  
  end
end
