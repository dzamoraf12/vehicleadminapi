class Vehicle < ApplicationRecord
  belongs_to :user

  enum :status, {
    disponible:        0,
    en_servicio:       1,
    en_taller:         2,
    fuera_de_servicio: 3
  }

  validates :license_plate, presence: true, uniqueness: { case_sensitive: false }
  validates :make, :model, :status, presence: true

  validates :year, presence: true,
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 1900,
      less_than_or_equal_to: Date.current.year + 1
    }

  scope :by_plate, ->(plate) { where("license_plate ILIKE ?", "%#{plate}%") if plate.present? }
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_user, ->(user_id) { where(user_id: user_id) if user_id.present? }

  def self.filter(params = {}, associations = {})
    filters = {
      by_status: params[:status],
      by_user: params[:user_id],
      by_plate: params[:license_plate]
    }

    FilteringService.new(self, filters, associations).filter
  end
end
