class AddValidationTokenAndTimestampToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :validation_token, :string
    add_column :sites, :validation_timestamp, :timestamp
  end

  def self.down
    remove_column :sites, :validation_token
    remove_column :sites, :validation_timestamp
  end
end
