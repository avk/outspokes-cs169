class CreateAppPolls < ActiveRecord::Migration
  def self.up
    create_table :app_polls do |t|
      t.text :can
      t.text :has
      t.text :will

      t.timestamps
    end
  end

  def self.down
    drop_table :app_polls
  end
end
