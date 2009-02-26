class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.integer :account_id
      t.integer :site_id
      t.text :url

      t.timestamps
    end
  end

  def self.down
    drop_table :pages
  end
end
