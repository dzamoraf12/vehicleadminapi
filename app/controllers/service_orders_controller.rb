class ServiceOrdersController < ApplicationController
  before_action :filter_list, only: %i[index]
  before_action :authorize_resource_access, only: %i[index]

  def index
    @resource = paginate @resource, per_page: per_page_params
    render json: render_serializer, status: :ok
  end

  private

  def filter_list
    parameters = filter_params
    filters = {
      status: parameters[:status],
      vehicle_id: parameters[:vehicle_id],
      created_at: parameters[:created_at_start]..parameters[:created_at_end]
    }
    associations = [ :vehicle, :maintenance_report ]
    @resource = ServiceOrder.filter(filters, associations)
  end

  def filter_params
    params.permit(:status, :vehicle_id, :created_at_start, :created_at_end, :per_page)
  end

  def render_serializer
    @serializer ||= ServiceOrderBlueprint.render_as_hash(@resource)
  end

  def authorize_resource_access
    authorize @resource || ServiceOrder
  end
end
