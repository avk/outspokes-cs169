class AddSiteNamesForExistingSites < ActiveRecord::Migration
  def self.up
    Site.all.each do |site|
      site.set_name!
    end
  end

  def self.down
    execute "UPDATE sites SET name = NULL;"
  end
end
