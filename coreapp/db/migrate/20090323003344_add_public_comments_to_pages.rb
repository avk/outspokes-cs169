class AddPublicCommentsToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :allow_public_comments, :boolean
  end

  def self.down
    remove_column :pages, :allow_public_comments
  end
end
