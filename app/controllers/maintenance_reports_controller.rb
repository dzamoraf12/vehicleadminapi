class MaintenanceReportsController < ApplicationController
  before_action :filter_list, only: %i[index]
  before_action :find_object, only: %i[show update]
  before_action :authorize_resource_access, only: %i[index create show update]

  def index
    @resource = paginate @resource, per_page: per_page_params
    render json: render_serializer, status: :ok
  end

  def create
    @resource = MaintenanceReport.create!(maintenance_report_params)
    render json: render_serializer, status: :created
  end

  def show
    render json: render_serializer, status: :ok
  end

  def update
    @resource.update!(maintenance_report_params)
    render json: render_serializer, status: :ok
  end

  private

  def filter_list
    begin
      params[:reported_at_start] = Date.parse(params[:reported_at_start]) if params[:reported_at_start].present?
      params[:reported_at_end] = Date.parse(params[:reported_at_end]) if params[:reported_at_end].present?
    rescue ArgumentError
      render json: { error: "Invalid date range format" }, status: :bad_request and return
    end

    parameters = filter_params
    filters = {
      vehicle_id: parameters[:vehicle_id],
      status: parameters[:status],
      user_id: parameters[:user_id],
      reported_at: parameters[:reported_at_start]..parameters[:reported_at_end],
      priority: parameters[:priority]
    }
    associations = []
    @resource = MaintenanceReport.filter(filters, associations)
  end

  def filter_params
    params.permit(:status, :user_id, :vehicle_id, :reported_at_start, :reported_at_end, :priority, :per_page)
  end

  def maintenance_report_params
    parameters = params.require(:maintenance_report).permit(:description, :priority, :reported_at, :vehicle_id)
    parameters[:priority] = nil if !MaintenanceReport.priorities.include?(parameters[:priority]) && action_name == "create"
    parameters[:status] = :pendiente if action_name == "create"
    parameters[:user_id] = current_user.id unless params[:id].present?

    parameters
  end

  def find_object
    @resource = MaintenanceReport.find_by!(id: params[:id])
  end

  def render_serializer
    @serializer ||= MaintenanceReportBlueprint.render_as_hash(@resource)
  end

  def authorize_resource_access
    authorize @resource || MaintenanceReport
  end
end
