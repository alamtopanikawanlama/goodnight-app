class Api::V1::UsersController < Api::V1::BaseController
  # GET /api/v1/users
  def index
    result = UserService.find_all(params)

    if result.success?
      response_data = {
        users: ActiveModelSerializers::SerializableResource.new(result.data, each_serializer: UserSerializer),
        pagination: result.meta
      }
      render json: response_data
      return
    end
    
    render_error(result.message)
  end

  # GET /api/v1/users/:id
  def show
    result = UserService.find_by_id(params[:id])

    if result.success?
      render json: result.data, serializer: UserSerializer, include: [:followers, :following]
      return
    end
    
    render_error(result.message, :not_found)
  end

  # POST /api/v1/users
  def create
    result = UserService.create(user_params)
    
    if result.success?
      render json: result.data, serializer: UserSerializer, status: :created
      return
    end
    
    render_error(result.message, :unprocessable_entity, result.errors)
  end

  # PATCH/PUT /api/v1/users/:id
  def update
    result = UserService.update(params[:id], user_params)
    
    if result.success?
      render json: result.data, serializer: UserSerializer
      return
    end
    
    render_error(result.message, :unprocessable_entity, result.errors)
  end

  # DELETE /api/v1/users/:id
  def destroy
    result = UserService.destroy(params[:id])
    
    if result.success?
      render_success(nil, result.message)
      return
    end
    
    render_error(result.message, :not_found)
  end

  # POST /api/v1/users/:id/follow
  def follow
    result = UserService.follow_user(params[:id], params[:target_user_id])
    
    if result.success?
      render_success(nil, result.message)
      return
    end
    
    render_error(result.message)
  end

  # DELETE /api/v1/users/:id/follow
  def unfollow
    result = UserService.unfollow_user(params[:id], params[:target_user_id])
    
    if result.success?
      render_success(nil, result.message)
      return
    end
    
    render_error(result.message)
  end

  # GET /api/v1/users/:id/followers
  def followers
    result = UserService.get_followers(params[:id], params)
    
    if result.success?
      response_data = {
        followers: ActiveModelSerializers::SerializableResource.new(result.data, each_serializer: UserSerializer),
        pagination: result.meta
      }
      render json: response_data
      return
    end
    
    render_error(result.message, :not_found)
  end

  # GET /api/v1/users/:id/following
  def following
    result = UserService.get_following(params[:id], params)
    
    if result.success?
      response_data = {
        following: ActiveModelSerializers::SerializableResource.new(result.data, each_serializer: UserSerializer),
        pagination: result.meta
      }
      render json: response_data
      return
    end
    
    render_error(result.message, :not_found)
  end

  private

  def user_params
    params.require(:user).permit(:name)
  end
end
