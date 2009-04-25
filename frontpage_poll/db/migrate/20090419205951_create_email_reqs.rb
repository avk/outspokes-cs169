class CreateEmailReqs < ActiveRecord::Migration
  def self.up
    create_table :email_reqs do |t|
      t.text :email

      t.timestamps
    end
  end

  def self.down
    drop_table :email_reqs
  end
end
