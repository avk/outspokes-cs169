class PopulateAccountNamesWithEmails < ActiveRecord::Migration
  def self.up
    Account.all.each do |account|
      account.update_attributes!({ :name => account.email }) if account.name.nil? or account.name.blank?
    end
  end

  def self.down
    Account.all.each do |account|
      account.update_attribute("name", nil)
    end
  end
end
