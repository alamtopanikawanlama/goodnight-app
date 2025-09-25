class Api::V1::SleepRecordsController < Api::V1::BaseController
  # GET /api/v1/users/:user_id/sleep_records
  def index
    cache_key = "sleep_records/index/#{params[:user_id]}/#{params.to_unsafe_h.to_param}"
    render_cached_or_fresh(cache_key) do
      result = SleepRecordService.find_all_by_user(
        params[:user_id], 
        page: params[:page], 
        per_page: params[:per_page]
      )
      if result.success?
        {
          sleep_records: ActiveModelSerializers::SerializableResource.new(result.data, each_serializer: SleepRecordSerializer).as_json,
          pagination: result.meta
        }
      else
        render_error(result.message, :not_found) and return
      end
    end
  end

  # GET /api/v1/users/:user_id/sleep_records/:id
  def show
    cache_key = "sleep_records/show/#{params[:user_id]}/#{params[:id]}"
    render_cached_or_fresh(cache_key) do
      result = SleepRecordService.find_by_id(params[:user_id], params[:id])
      if result.success?
        ActiveModelSerializers::SerializableResource.new(result.data, serializer: SleepRecordSerializer).as_json
      else
        render_error(result.message, :not_found) and return
      end
    end
  end

  # POST /api/v1/users/:user_id/sleep_records/clock_in
  def clock_in
    result = SleepRecordService.clock_in(params[:user_id])
    Rails.cache.delete_matched("sleep_records/*#{params[:user_id]}*")
    if result.success?
      render json: result.data, serializer: SleepRecordSerializer, status: :created
      return
    end
    render_error(result.message)
  end

  # PATCH /api/v1/users/:user_id/sleep_records/:id/clock_out
  def clock_out
    result = SleepRecordService.clock_out(params[:user_id])
    Rails.cache.delete_matched("sleep_records/*#{params[:user_id]}*")
    if result.success?
      render json: result.data, serializer: SleepRecordSerializer
      return
    end
    render_error(result.message)
  end

  # GET /api/v1/users/:user_id/sleep_records/current
  def current
    cache_key = "sleep_records/current/#{params[:user_id]}"
    render_cached_or_fresh(cache_key) do
      result = SleepRecordService.get_current(params[:user_id])
      if result.success?
        ActiveModelSerializers::SerializableResource.new(result.data, serializer: SleepRecordSerializer).as_json
      else
        render_error(result.message, :not_found) and return
      end
    end
  end

  # GET /api/v1/users/:user_id/sleep_records/friends
  def friends
    cache_key = "sleep_records/friends/#{params[:user_id]}/#{params.to_unsafe_h.to_param}"
    render_cached_or_fresh(cache_key) do
      result = SleepRecordService.get_friends_records(
        params[:user_id],
        page: params[:page],
        per_page: params[:per_page]
      )
      if result.success?
        {
          friends_sleep_records: ActiveModelSerializers::SerializableResource.new(result.data, each_serializer: SleepRecordSerializer).as_json,
          pagination: result.meta
        }
      else
        render_error(result.message, :not_found) and return
      end
    end
  end

  # DELETE /api/v1/users/:user_id/sleep_records/:id
  def destroy
    result = SleepRecordService.destroy(params[:user_id], params[:id])
    Rails.cache.delete_matched("sleep_records/*#{params[:user_id]}*")
    if result.success?
      head :no_content # status 204
    else
      render_error(result.message, :not_found)
    end
  end
end
