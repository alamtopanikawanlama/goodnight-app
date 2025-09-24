class FollowService < BaseService
  class << self
    def find_all(params = {})
      follows = Follow.all.includes(:follower, :following)
      page = params[:page] || 1
      per_page = params[:per_page] || 20

      paginated_follows = follows.page(page).per(per_page)
      
      ServiceResult.new(
        success: true, 
        data: paginated_follows,
        meta: {
          current_page: paginated_follows.current_page,
          total_pages: paginated_follows.total_pages,
          total_count: paginated_follows.total_count,
          per_page: per_page.to_i,
          next_page: paginated_follows.next_page,
          prev_page: paginated_follows.prev_page
        }
      )
    end

    def find_by_id(id)
      follow = Follow.find(id)
      ServiceResult.new(success: true, data: follow)
    rescue ActiveRecord::RecordNotFound => e
      ServiceResult.new(success: false, message: e.message)
    end

    def create(params)
      follow = Follow.new(params)
      
      if follow.save
        ServiceResult.new(success: true, data: follow, message: 'Follow relationship created successfully')
      else
        ServiceResult.new(success: false, message: 'Failed to create follow relationship', errors: follow.errors.full_messages)
      end
    end

    def destroy(id)
      follow = Follow.find(id)
      follow.destroy
      
      ServiceResult.new(success: true, message: 'Follow relationship deleted successfully')
    rescue ActiveRecord::RecordNotFound => e
      ServiceResult.new(success: false, message: e.message)
    end
  end
end
