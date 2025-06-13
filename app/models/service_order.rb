class ServiceOrder < ApplicationRecord
  belongs_to :vehicle
  belongs_to :maintenance_report

  enum :status, { abierta: 0, en_progreso: 1, cerrada: 2 }

  validates :estimated_cost,
    presence: true,
    numericality: { greater_than_or_equal_to: 0 }
end
