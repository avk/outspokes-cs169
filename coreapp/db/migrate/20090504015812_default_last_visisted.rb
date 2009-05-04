class DefaultLastVisisted < ActiveRecord::Migration
  def self.up
    execute "UPDATE commenters SET last_visited_at = updated_at;"
  end

  def self.down
  end
end
