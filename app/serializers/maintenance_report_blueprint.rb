class MaintenanceReportBlueprint < Blueprinter::Base
  identifier :id
  fields :description, :priority, :reported_at, :status

  association :vehicle, blueprint: VehicleBlueprint
  association :user, blueprint: UserBlueprint
end