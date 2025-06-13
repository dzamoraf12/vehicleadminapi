class ServiceOrder < ApplicationRecord
  belongs_to :vehicle
  belongs_to :maintenance_report

  enum :status, { abierta: 0, en_progreso: 1, cerrada: 2 }

  validates :estimated_cost,
    presence: true,
    numericality: { greater_than_or_equal_to: 0 }

  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_vehicle, ->(vehicle_id) { where(vehicle_id: vehicle_id) if vehicle_id.present? }
  scope :by_created_at, ->(created_at_range) { where(created_at: created_at_range) if created_at_range.present? }

  def self.filter(params = {}, associations = {})
    return self.all if params.blank?

    filters = {
      by_status: params[:status],
      by_vehicle: params[:vehicle_id],
      by_created_at: params[:created_at]
    }

    FilteringService.new(self, filters, associations).filter
  end
end
