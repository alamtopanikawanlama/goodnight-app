class UserService < BaseService
  class << self
    def find_all(params = {})
      users = User.all.includes(:followers, :following)
      page = params[:page] || 1
      per_page = params[:per_page] || 20
      
      paginated_users = users.page(page).per(per_page)
      
      ServiceResult.new(
        success: true, 
        data: paginated_users,
        meta: {
          current_page: paginated_users.current_page,
          total_pages: paginated_users.total_pages,
          total_count: paginated_users.total_count,
          per_page: per_page.to_i,
          next_page: paginated_users.next_page,
          prev_page: paginated_users.prev_page
        }
      )
    end

    def find_by_id(id)
      user = User.find(id)
      ServiceResult.new(success: true, data: user)
    rescue ActiveRecord::RecordNotFound => e
      ServiceResult.new(success: false, message: e.message)
    end

    def create(params)
      user = User.new(params)
      
      if user.save
        ServiceResult.new(success: true, data: user, message: 'User created successfully')
      else
        ServiceResult.new(success: false, message: 'Failed to create user', errors: user.errors.full_messages)
      end
    end

    def update(id, params)
      user = User.find(id)
      
      if user.update(params)
        ServiceResult.new(success: true, data: user, message: 'User updated successfully')
      else
        ServiceResult.new(success: false, message: 'Failed to update user', errors: user.errors.full_messages)
      end
    rescue ActiveRecord::RecordNotFound => e
      ServiceResult.new(success: false, message: e.message)
    end

    def destroy(id)
      user = User.find(id)
      user.destroy
      ServiceResult.new(success: true, message: 'User deleted successfully')
    rescue ActiveRecord::RecordNotFound => e
      ServiceResult.new(success: false, message: e.message)
    end

    def follow_user(follower_id, target_user_id)
      follower = User.find(follower_id)
      target_user = User.find(target_user_id)
      
      if follower.follow(target_user)
        ServiceResult.new(success: true, message: 'Successfully followed user')
      else
        ServiceResult.new(success: false, message: 'Failed to follow user')
      end
    rescue ActiveRecord::RecordNotFound => e
      ServiceResult.new(success: false, message: e.message)
    end

    def unfollow_user(follower_id, target_user_id)
      follower = User.find(follower_id)
      target_user = User.find(target_user_id)
      
      if follower.unfollow(target_user)
        ServiceResult.new(success: true, message: 'Successfully unfollowed user')
      else
        ServiceResult.new(success: false, message: 'Failed to unfollow user')
      end
    rescue ActiveRecord::RecordNotFound => e
      ServiceResult.new(success: false, message: e.message)
    end

    def get_followers(id, params = {})
      user = User.find(id)
      page = params[:page] || 1
      per_page = params[:per_page] || 20
      
      paginated_followers = user.followers.page(page).per(per_page)
      
      ServiceResult.new(
        success: true, 
        data: paginated_followers,
        meta: {
          current_page: paginated_followers.current_page,
          total_pages: paginated_followers.total_pages,
          total_count: paginated_followers.total_count,
          per_page: per_page.to_i,
          next_page: paginated_followers.next_page,
          prev_page: paginated_followers.prev_page
        }
      )
    rescue ActiveRecord::RecordNotFound => e
      ServiceResult.new(success: false, message: e.message)
    end

    def get_following(id, params = {})
      user = User.find(id)
      page = params[:page] || 1
      per_page = params[:per_page] || 20
      
      paginated_following = user.following.page(page).per(per_page)
      
      ServiceResult.new(
        success: true, 
        data: paginated_following,
        meta: {
          current_page: paginated_following.current_page,
          total_pages: paginated_following.total_pages,
          total_count: paginated_following.total_count,
          per_page: per_page.to_i,
          next_page: paginated_following.next_page,
          prev_page: paginated_following.prev_page
        }
      )
    rescue ActiveRecord::RecordNotFound => e
      ServiceResult.new(success: false, message: e.message)
    end
  end
end
