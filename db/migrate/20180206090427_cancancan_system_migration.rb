# frozen_string_literal: true

class CancancanSystemMigration < ActiveRecord::Migration[5.1]
  def change
    add_column :belongings, :ability, :string, default: 'guest'
  end
end
