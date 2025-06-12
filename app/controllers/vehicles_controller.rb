class VehiclesController < ApplicationController
  before_action :filter_list, only: %i[index]

  def index
    @resource = paginate @resource, per_page: per_page_params
    render json: render_serializer, status: :ok
  end

  private

  def filter_list
    parameters = filter_params
    filters = {
      license_plate: parameters[:license_plate],
      status: parameters[:status],
      user_id: parameters[:user_id]
    }
    associations = [ ]
    @resource = Vehicle.filter(filters, associations)
  end

  def filter_params
    params.permit(:license_plate, :status, :user_id, :per_page)
  end

  def render_serializer
    @serializer ||= VehicleBlueprint.render_as_hash(@resource)
  end
end
