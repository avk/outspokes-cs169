class AllowDuplicateEmailsInCommenters < ActiveRecord::Migration
  def self.up
    remove_index :commenters, :email  # index used to be uniq
    add_index :commenters, :email
  end

  def self.down
    remove_index :commenters, :email
    add_index :commenters, :email, :unique => true
  end
end
