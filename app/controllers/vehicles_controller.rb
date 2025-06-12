class VehiclesController < ApplicationController
  before_action :filter_list, only: %i[index]
  before_action :find_object, only: %i[show update]

  def index
    @resource = paginate @resource, per_page: per_page_params
    render json: render_serializer, status: :ok
  end

  def create
    @resource = Vehicle.create!(vehicle_params)
    render json: render_serializer, status: :created
  end

  def show
    render json: render_serializer, status: :ok
  end

  def update
    @resource.update!(vehicle_params)
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

  def vehicle_params
    parameters = params.require(:vehicle).permit(:license_plate, :make, :model, :year, :status)
    parameters[:status] = nil if !Vehicle.statuses.include?(parameters[:status]) && action_name == "create"
    parameters[:user_id] = current_user.id unless params[:id].present?

    parameters
  end

  def find_object
    @resource = Vehicle.find_by!(id: params[:id])
  end

  def render_serializer
    @serializer ||= VehicleBlueprint.render_as_hash(@resource)
  end
end
