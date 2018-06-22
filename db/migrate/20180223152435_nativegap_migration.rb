class NativegapMigration < ActiveRecord::Migration[5.1]
    def change
        create_table :native_gap_apps do |t|

            t.references :owner, polymorphic: true, index: true

            t.string :platform, index: true
            t.string :url, index: true

            t.datetime :last_used

            t.timestamps

        end
    end
end
