class AddPlanNameToAccounts < ActiveRecord::Migration
  def self.up
    add_column :commenters, :plan_name, :string, :default => 'free'
  end

  def self.down
    remove_column :commenters, :plan_name
  end
end
