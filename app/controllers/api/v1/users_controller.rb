class Api::V1::UsersController < Api::V1::BaseController
  # GET /api/v1/users
  def index
    cache_key = "users/index/#{params.to_unsafe_h.to_param}"
    render_cached_or_fresh(cache_key) do
      result = UserService.find_all(params)
      if result.success?
        {
          users: ActiveModelSerializers::SerializableResource.new(result.data, each_serializer: UserSerializer).as_json,
          pagination: result.meta
        }
      else
        render_error(result.message) and return
      end
    end
  end

  # GET /api/v1/users/:id
  def show
    cache_key = "users/show/#{params[:id]}"
    render_cached_or_fresh(cache_key) do
      result = UserService.find_by_id(params[:id])
      if result.success?
        ActiveModelSerializers::SerializableResource.new(
          result.data,
          serializer: UserSerializer,
          include: [:followers, :following]
        ).as_json
      else
        render_error(result.message, :not_found) and return
      end
    end
  end

  # POST /api/v1/users
  def create
    result = UserService.create(user_params)
    Rails.cache.delete_matched("users/*")
    if result.success?
      render json: result.data, serializer: UserSerializer, status: :created
    else
      render_error(result.message, :unprocessable_entity, result.errors)
    end
  end

  # PATCH/PUT /api/v1/users/:id
  def update
    result = UserService.update(params[:id], user_params)
    Rails.cache.delete_matched("users/*")
    if result.success?
      render json: result.data, serializer: UserSerializer
    else
      render_error(result.message, :unprocessable_entity, result.errors)
    end
  end

  # DELETE /api/v1/users/:id
  def destroy
    result = UserService.destroy(params[:id])
    Rails.cache.delete_matched("users/*")
    if result.success?
      head :no_content # status 204
    else
      render_error(result.message, :not_found)
    end
  end

  # POST /api/v1/users/:id/follow
  def follow
    result = UserService.follow_user(params[:id], params[:target_user_id])
    Rails.cache.delete_matched("users/*")
    if result.success?
      render_success(nil, result.message)
    else
      render_error(result.message)
    end
  end

  # DELETE /api/v1/users/:id/follow
  def unfollow
    result = UserService.unfollow_user(params[:id], params[:target_user_id])
    Rails.cache.delete_matched("users/*")
    if result.success?
      head :no_content # status 204
    else
      render_error(result.message)
    end
  end

  # GET /api/v1/users/:id/followers
  def followers
    cache_key = "users/#{params[:id]}/followers/#{params.to_unsafe_h.to_param}"
    render_cached_or_fresh(cache_key) do
      result = UserService.get_followers(params[:id], params)
      if result.success?
        {
          followers: ActiveModelSerializers::SerializableResource.new(result.data, each_serializer: UserSerializer).as_json,
          pagination: result.meta
        }
      else
        render_error(result.message, :not_found) and return
      end
    end
  end

  # GET /api/v1/users/:id/following
  def following
    cache_key = "users/#{params[:id]}/following/#{params.to_unsafe_h.to_param}"
    render_cached_or_fresh(cache_key) do
      result = UserService.get_following(params[:id], params)
      if result.success?
        {
          following: ActiveModelSerializers::SerializableResource.new(result.data, each_serializer: UserSerializer).as_json,
          pagination: result.meta
        }
      else
        render_error(result.message, :not_found) and return
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(:name)
  end
end
