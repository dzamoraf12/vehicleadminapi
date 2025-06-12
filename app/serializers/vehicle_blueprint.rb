class VehicleBlueprint < Blueprinter::Base
  identifier :id
  fields :license_plate, :make, :model, :year, :status
end