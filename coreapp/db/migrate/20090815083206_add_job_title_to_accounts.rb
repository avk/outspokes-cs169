class AddJobTitleToAccounts < ActiveRecord::Migration
  def self.up
    add_column :commenters, :job_title, :string
  end

  def self.down
    remove_column :commenters, :job_title
  end
end
