class MaintenanceReport < ApplicationRecord
  belongs_to :vehicle
  belongs_to :user

  enum :priority, { baja: 0, media: 1, alta: 2 }
  enum :status,   { pendiente: 0, procesado: 1, rechazado: 2 }
end
