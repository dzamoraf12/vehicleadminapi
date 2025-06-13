class ServiceOrderBlueprint < Blueprinter::Base
  identifier :id
  fields :estimated_cost, :status, :created_at

  association :vehicle, blueprint: VehicleBlueprint
  association :maintenance_report, blueprint: MaintenanceReportBlueprint
end
