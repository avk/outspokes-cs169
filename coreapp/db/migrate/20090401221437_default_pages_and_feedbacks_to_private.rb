class DefaultPagesAndFeedbacksToPrivate < ActiveRecord::Migration
  def self.up
    change_column :feedbacks, :public, :boolean, :default => 0, :null => false
    change_column :pages, :allow_public_comments, :boolean, :default => 0, :null => false
  end

  def self.down
  end
end
