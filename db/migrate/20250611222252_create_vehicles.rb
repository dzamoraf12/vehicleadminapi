class CreateVehicles < ActiveRecord::Migration[8.0]
  def change
    create_table :vehicles do |t|
      t.string :license_plate
      t.string :make
      t.string :model
      t.integer :year
      t.integer :status
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :vehicles, :license_plate, unique: true
    add_index :vehicles, :status
  end
end
