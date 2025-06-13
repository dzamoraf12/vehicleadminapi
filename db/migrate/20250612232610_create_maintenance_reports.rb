class CreateMaintenanceReports < ActiveRecord::Migration[8.0]
  def change
    create_table :maintenance_reports do |t|
      t.text :description
      t.integer :priority
      t.integer :status
      t.datetime :reported_at
      t.references :vehicle, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :maintenance_reports, [ :status, :priority ]
    add_index :maintenance_reports, :reported_at
    add_index :maintenance_reports, [ :status, :reported_at ]
    add_index :maintenance_reports, [ :vehicle_id, :status ]
  end
end
