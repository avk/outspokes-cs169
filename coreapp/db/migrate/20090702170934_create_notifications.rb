class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.references :site
      t.string :aasm_state
      t.timestamps
    end

    create_table :feedbacks_notifications, :id => false do |t|
      t.references :feedback
      t.references :notification
    end

    create_table :notifications_opinions, :id => false do |t|
      t.references :opinion
      t.references :notification
    end
  end

  def self.down
    drop_table :opinions_notifications
    drop_table :feedbacks_notifications
    drop_table :notifications
  end
end
