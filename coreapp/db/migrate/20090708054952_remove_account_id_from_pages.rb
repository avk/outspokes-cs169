class RemoveAccountIdFromPages < ActiveRecord::Migration
  def self.up
    remove_column :pages, :account_id
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
