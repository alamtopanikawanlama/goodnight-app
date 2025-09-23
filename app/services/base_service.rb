class BaseService
  include ActiveModel::Model
  include ActiveModel::Attributes

  def self.call(*args, **kwargs)
    new(*args, **kwargs).call
  end

  def call
    raise NotImplementedError, "#{self.class} must implement #call"
  end

  private

  def success(data = nil, message = 'Success')
    ServiceResult.new(success: true, data: data, message: message)
  end

  def failure(message = 'Failed', errors = [])
    ServiceResult.new(success: false, message: message, errors: errors)
  end
end

class ServiceResult
  attr_reader :data, :message, :errors, :meta

  def initialize(success:, data: nil, message: nil, errors: [], meta: nil)
    @success = success
    @data = data
    @message = message
    @errors = errors
    @meta = meta
  end

  def success?
    @success
  end

  def failure?
    !@success
  end
end
