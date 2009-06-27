class RemoveBullshits < ActiveRecord::Migration
  def self.up
    drop_table :bullshits
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
