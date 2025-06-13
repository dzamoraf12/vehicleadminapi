# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

admin = User.find_or_create_by!(email: ENV.fetch("API_ADMIN_USER_EMAIL") { "admin@vehicles.com" }) do |user|
  user.password = ENV.fetch("API_ADMIN_USER_PASS") { "password" }
  user.password_confirmation = ENV.fetch("API_ADMIN_USER_PASS") { "password" }
  user.role = :admin
end

User.find_or_create_by!(email: ENV.fetch("API_TECHNICIAN_USER_EMAIL") { "technician@vehicles.com" }) do |user|
  user.password = ENV.fetch("API_TECHNICIAN_USER_PASS") { "password" }
  user.password_confirmation = ENV.fetch("API_TECHNICIAN_USER_PASS") { "password" }
  user.role = :tecnico
end

driver = User.find_or_create_by!(email: ENV.fetch("API_DRIVER_USER_EMAIL") { "driver@vehicles.com" }) do |user|
  user.password = ENV.fetch("API_DRIVER_USER_PASS") { "password" }
  user.password_confirmation = ENV.fetch("API_DRIVER_USER_PASS") { "password" }
  user.role = :chofer
end

# ----------------------------
# Vehicles
# ----------------------------
vehicles_data = [
  { license_plate: "ABC123", make: "Toyota",        model: "Hilux",   year: 2021, status: :disponible },
  { license_plate: "DEF456", make: "Ford",          model: "Transit", year: 2019, status: :disponible },
  { license_plate: "GHI789", make: "Mercedes-Benz", model: "Actros",  year: 2020, status: :disponible }
]

vehicles_data.map do |attrs|
  Vehicle.find_or_create_by!(license_plate: attrs[:license_plate]) do |v|
    v.make  = attrs[:make]
    v.model = attrs[:model]
    v.year  = attrs[:year]
    v.status = attrs[:status]
    v.user = admin
  end
end

# ----------------------------
# Maintenance Reports
# ----------------------------
reports_data = [
  { vehicle_plate: "ABC123", description: "Brake pads worn out",  priority: :alta, status: :pendiente, reported_at: 2.days.ago },
  { vehicle_plate: "DEF456", description: "Oil leak detected",    priority: :media, status: :pendiente, reported_at: 1.day.ago  },
  { vehicle_plate: "GHI789", description: "Engine overheating",   priority: :alta, status: :procesado, reported_at: 3.days.ago }
]

reports = reports_data.map do |attrs|
  vehicle = Vehicle.find_by!(license_plate: attrs.delete(:vehicle_plate))
  MaintenanceReport.find_or_create_by!(
    vehicle: vehicle,
    user:    driver,
    reported_at: attrs[:reported_at]
  ) do |r|
    r.description = attrs[:description]
    r.priority    = attrs[:priority]
    r.status      = attrs[:status]
  end
end

# ----------------------------
# Service Orders
# ----------------------------
# only create service orders for reports with high priority
orders_data = reports.select { |r| r.priority == "alta" }.map do |r|
  {
    maintenance_report: r,
    vehicle: r.vehicle,
    estimated_cost: [ 1500, 3000, 4500 ].sample,
    status: (r.status == "pendiente" ? :abierta : :cerrada),
    created_at: r.reported_at + 1.hour
  }
end

orders_data.each do |attrs|
  ServiceOrder.find_or_create_by!(
    maintenance_report: attrs[:maintenance_report],
    vehicle: attrs[:vehicle]
  ) do |o|
    o.estimated_cost     = attrs[:estimated_cost]
    o.status             = attrs[:status]
    o.created_at         = attrs[:created_at]
  end
end
