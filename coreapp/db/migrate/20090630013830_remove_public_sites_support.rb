class RemovePublicSitesSupport < ActiveRecord::Migration
  def self.up
    remove_column :feedbacks, :name
    remove_column :feedbacks, :public
    remove_column :pages, :allow_public_comments
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
