class RemoveUrlFromSites < ActiveRecord::Migration
  def self.up
    remove_column :sites, :url
  end

  def self.down
    add_column :sites, :url, :string
  end
end
