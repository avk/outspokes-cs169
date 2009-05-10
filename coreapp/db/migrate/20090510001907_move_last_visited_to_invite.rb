class MoveLastVisitedToInvite < ActiveRecord::Migration
  def self.up
    add_column :invites, :last_visited_at, :timestamp
    remove_column :commenters, :last_visited_at
    execute "UPDATE invites SET last_visited_at = updated_at;"
  end

  def self.down
    add_column :commenters, :last_visited_at, :timestamp
    remove_column :invites, :last_visited_at
    execute "UPDATE commenters SET last_visited_at = updated_at;"
  end
end