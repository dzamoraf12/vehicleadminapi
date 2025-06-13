class MaintenanceReport < ApplicationRecord
  belongs_to :vehicle
  belongs_to :user

  enum :priority, { baja: 0, media: 1, alta: 2 }
  enum :status,   { pendiente: 0, procesado: 1, rechazado: 2 }

  validates :description, :priority, :status, :reported_at, presence: true
  validate  :reported_at_cannot_be_in_the_future

  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_user, ->(user_id) { where(user_id: user_id) if user_id.present? }
  scope :by_vehicle, ->(vehicle_id) { where(vehicle_id: vehicle_id) if vehicle_id.present? }
  scope :by_priority, ->(priority) { where(priority: priority) if priority.present? }
  scope :by_reported_at, ->(reported_at_range) { where(reported_at: reported_at_range) if reported_at_range.present? }

  def self.filter(params = {}, associations = {})
    return self.all if params.blank?

    filters = {
      by_status: params[:status],
      by_user: params[:user_id],
      by_vehicle: params[:vehicle_id],
      by_priority: params[:priority],
      by_reported_at: params[:reported_at]
    }

    FilteringService.new(self, filters, associations).filter
  end

  private

  def reported_at_cannot_be_in_the_future
    if reported_at.present? && reported_at > Date.current
      errors.add(:reported_at, "can't be in the future")
    end
  end
end
