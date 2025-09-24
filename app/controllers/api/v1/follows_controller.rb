class Api::V1::FollowsController < Api::V1::BaseController
  # GET /api/v1/follows
  def index
    result = FollowService.find_all(params)
    
    if result.success?
      response_data = {
        follows: ActiveModelSerializers::SerializableResource.new(result.data, each_serializer: FollowSerializer),
        pagination: result.meta
      }
      render json: response_data
      return
    end
    
    render_error(result.message)
  end

  # GET /api/v1/follows/:id
  def show
    result = FollowService.find_by_id(params[:id])
    
    if result.success?
      render json: result.data, serializer: FollowSerializer
      return
    end
    
    render_error(result.message, :not_found)
  end

  # POST /api/v1/follows
  def create
    result = FollowService.create(follow_params)
    
    if result.success?
      render json: result.data, serializer: FollowSerializer, status: :created
      return
    end
    
    render_error(result.message, :unprocessable_entity, result.errors)
  end

  # DELETE /api/v1/follows/:id
  def destroy
    result = FollowService.destroy(params[:id])
    
    if result.success?
      render_success(nil, result.message)
      return
    end
    
    render_error(result.message, :not_found)
  end

  private

  def follow_params
    params.require(:follow).permit(:follower_id, :following_id)
  end
end
