class Api::V1::FollowsController < Api::V1::BaseController
  # GET /api/v1/follows
  def index
    cache_key = "follows/index/#{params.to_unsafe_h.to_param}"
    render_cached_or_fresh(cache_key) do
      result = FollowService.find_all(params)
      if result.success?
        {
          follows: ActiveModelSerializers::SerializableResource.new(result.data, each_serializer: FollowSerializer).as_json,
          pagination: result.meta
        }
      else
        render_error(result.message) and return
      end
    end
  end

  # GET /api/v1/follows/:id
  def show
    cache_key = "follows/show/#{params[:id]}"
    render_cached_or_fresh(cache_key) do
      result = FollowService.find_by_id(params[:id])
      if result.success?
        ActiveModelSerializers::SerializableResource.new(result.data, serializer: FollowSerializer).as_json
      else
        render_error(result.message, :not_found) and return
      end
    end
  end

  # POST /api/v1/follows
  def create
    result = FollowService.create(follow_params)
    Rails.cache.delete_matched("follows/*")
    if result.success?
      render json: result.data, serializer: FollowSerializer, status: :created
    else
      render_error(result.message, :unprocessable_entity, result.errors)
    end
  end

  # DELETE /api/v1/follows/:id
  def destroy
    result = FollowService.destroy(params[:id])
    Rails.cache.delete_matched("follows/*")
    if result.success?
      head :no_content # status 204
    else
      render_error(result.message, :not_found)
    end
  end

  private

  def follow_params
    params.require(:follow).permit(:follower_id, :following_id)
  end
end
