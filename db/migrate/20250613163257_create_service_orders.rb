class CreateServiceOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :service_orders do |t|
      t.decimal :estimated_cost
      t.integer :status
      t.references :vehicle, null: false, foreign_key: true
      t.references :maintenance_report, null: false, foreign_key: true

      t.timestamps
    end

    add_index :service_orders, :status
    add_index :service_orders, [ :status, :vehicle_id ]
    add_index :service_orders, :created_at
  end
end
