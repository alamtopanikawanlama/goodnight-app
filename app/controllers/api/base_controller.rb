class Api::BaseController < ApplicationController
  protect_from_forgery with: :null_session
  
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from ActionController::ParameterMissing, with: :parameter_missing

  private

  def record_not_found(exception)
    render json: {
      error: 'Record not found',
      message: exception.message
    }, status: :not_found
  end

  def record_invalid(exception)
    render json: {
      error: 'Validation failed',
      message: exception.message,
      details: exception.record.errors.full_messages
    }, status: :unprocessable_entity
  end

  def parameter_missing(exception)
    render json: {
      error: 'Parameter missing',
      message: exception.message
    }, status: :bad_request
  end

  def render_success(data = nil, message = 'Success', status = :ok)
    response = { status: 'success', message: message }
    response[:data] = data if data
    render json: response, status: status
  end

  def render_error(message, status = :bad_request, details = nil)
    response = { status: 'error', message: message }
    response[:details] = details if details
    render json: response, status: status
  end
end
