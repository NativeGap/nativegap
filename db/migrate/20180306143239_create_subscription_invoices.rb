class CreateSubscriptionInvoices < ActiveRecord::Migration[5.1]
  def change
    create_table :subscription_invoices do |t|
      t.references :subscription, index: true

      t.integer :amount

      t.timestamps
    end
  end
end
