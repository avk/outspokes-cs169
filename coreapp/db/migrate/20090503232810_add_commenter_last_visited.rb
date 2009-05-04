class AddCommenterLastVisited < ActiveRecord::Migration
  def self.up
    add_column :commenters, :last_visited_at, :timestamp
  end

  def self.down
    remove_column :commenters, :last_visisted_at
  end
end
