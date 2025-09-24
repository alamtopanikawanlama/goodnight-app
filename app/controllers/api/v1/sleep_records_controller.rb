class Api::V1::SleepRecordsController < Api::V1::BaseController
  # GET /api/v1/users/:user_id/sleep_records
  def index
    result = SleepRecordService.find_all_by_user(
      params[:user_id], 
      page: params[:page], 
      per_page: params[:per_page]
    )
    
    if result.success?
      response_data = {
        sleep_records: ActiveModelSerializers::SerializableResource.new(result.data, each_serializer: SleepRecordSerializer),
        pagination: result.meta
      }
      render json: response_data
      return
    end
    
    render_error(result.message, :not_found)
  end

  # GET /api/v1/users/:user_id/sleep_records/:id
  def show
    result = SleepRecordService.find_by_id(params[:user_id], params[:id])
    
    if result.success?
      render json: result.data, serializer: SleepRecordSerializer
      return
    end
    
    render_error(result.message, :not_found)
  end

  # POST /api/v1/users/:user_id/sleep_records/clock_in
  def clock_in
    result = SleepRecordService.clock_in(params[:user_id])
    
    if result.success?
      render json: result.data, serializer: SleepRecordSerializer, status: :created
      return
    end
    
    render_error(result.message)
  end

  # PATCH /api/v1/users/:user_id/sleep_records/:id/clock_out
  def clock_out
    result = SleepRecordService.clock_out(params[:user_id])
    
    if result.success?
      render json: result.data, serializer: SleepRecordSerializer
      return
    end
    
    render_error(result.message)
  end

  # GET /api/v1/users/:user_id/sleep_records/current
  def current
    result = SleepRecordService.get_current(params[:user_id])
    
    if result.success?
      render json: result.data, serializer: SleepRecordSerializer
      return
    end
    
    render_error(result.message, :not_found)
  end

  # GET /api/v1/users/:user_id/sleep_records/friends
  def friends
    result = SleepRecordService.get_friends_records(
      params[:user_id],
      page: params[:page],
      per_page: params[:per_page]
    )
    
    if result.success?
      response_data = {
        friends_sleep_records: ActiveModelSerializers::SerializableResource.new(result.data, each_serializer: SleepRecordSerializer),
        pagination: result.meta
      }
      render json: response_data
      return
    end
    
    render_error(result.message, :not_found)
  end

  # DELETE /api/v1/users/:user_id/sleep_records/:id
  def destroy
    result = SleepRecordService.destroy(params[:user_id], params[:id])
    
    if result.success?
      render_success(nil, result.message)
      return
    end
    
    render_error(result.message, :not_found)
  end
end
