class ApplicationController < ActionController::API
  include Pagy::Backend

  respond_to :json

  before_action :authenticate_user!

  rescue_from Pagy::OverflowError, with: :pagy_overflow_error
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid_error
  rescue_from ActionController::ParameterMissing, with: :bad_request_error

  def respond_with(resource, opts = {})
    status = opts[:status] || :ok
    blueprint = blueprint_for(resource)
    if blueprint
      render json: blueprint.render(resource), status: status
    else
      render json: resource, status: status
    end
  end

  def authenticate_user!
    unless current_user
      render json: { error: "User not logged in" }, status: :unauthorized and return
    end
  end

  private

  def per_page_params
    params[:per_page] || 10
  end

  def blueprint_for(resource)
    "#{resource.class.name}Blueprint".constantize
  rescue NameError
    nil
  end

  def pagy_overflow_error(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  def unauthorized_error(exception)
    render json: { error: exception.message }, status: :unauthorized
  end

  def record_invalid_error(e)
    error_hash = e.record.errors
    error_full_messages = e.record.errors.full_messages
    
    render json: { error_hash: error_hash, full_messages: error_full_messages },
           status: :unprocessable_entity
  end

  def bad_request_error(exception)
    render json: { error: exception.message }, status: :bad_request
  end
end
