class AddNameToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :name, :string, :limit => 50
  end

  def self.down
    remove_column :sites, :name
  end
end
