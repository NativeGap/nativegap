# frozen_string_literal: true

class ActsAsBelongableMigration < ActiveRecord::Migration[5.1]
  def change
    create_table :belongings do |t|
      t.references :belonger, polymorphic: true, index: true
      t.references :belongable, polymorphic: true, index: true

      t.string :scope
      t.integer :position

      t.timestamps
    end
  end
end
