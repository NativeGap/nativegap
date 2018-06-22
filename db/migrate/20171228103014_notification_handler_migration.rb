class NotificationHandlerMigration < ActiveRecord::Migration[5.1]
    def change
        create_table :notifications do |t|

            t.references :target, polymorphic: true, index: true
            t.references :object, polymorphic: true, index: true

            t.boolean :read, default: false, null: false, index: true

            t.text :metadata

            t.timestamps

        end
    end
end
