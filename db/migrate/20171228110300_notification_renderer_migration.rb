class NotificationRendererMigration < ActiveRecord::Migration[5.1]
  def change
    add_column :notifications, :type, :string, index: true
  end
end
