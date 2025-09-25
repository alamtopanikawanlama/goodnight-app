class SleepRecordService < BaseService
  class << self
    def find_all_by_user(user_id, page: nil, per_page: 20)
      user = User.find(user_id)
      sleep_records = user.sleep_records.includes(:user).order(created_at: :desc)
      page = page || 1
      paginated_sleep_records = sleep_records.page(page).per(per_page)
      
      ServiceResult.new(
        success: true, 
        data: paginated_sleep_records,
        meta: {
          current_page: paginated_sleep_records.current_page,
          total_pages: paginated_sleep_records.total_pages,
          total_count: paginated_sleep_records.total_count,
          per_page: per_page.to_i,
          next_page: paginated_sleep_records.next_page,
          prev_page: paginated_sleep_records.prev_page
        }
      )
    rescue ActiveRecord::RecordNotFound => e
      ServiceResult.new(success: false, message: e.message)
    end

    def find_by_id(user_id, sleep_record_id)
      user = User.find(user_id)
      sleep_record = user.sleep_records.find(sleep_record_id)
      
      ServiceResult.new(success: true, data: sleep_record)
    rescue ActiveRecord::RecordNotFound => e
      ServiceResult.new(success: false, message: e.message)
    end

    def clock_in(user_id)
      user = User.find(user_id)
      
      if user.clock_in
        current_record = user.send(:current_sleep_record)
        ServiceResult.new(success: true, data: current_record, message: 'Successfully clocked in')
      else
        ServiceResult.new(success: false, message: 'Failed to clock in. User might already have an ongoing sleep record.')
      end
    rescue ActiveRecord::RecordNotFound => e
      ServiceResult.new(success: false, message: e.message)
    end

    def clock_out(user_id)
      user = User.find(user_id)
      
      if user.clock_out
        # Get the updated record
        current_record = user.sleep_records.completed.order(created_at: :desc).first
        ServiceResult.new(success: true, data: current_record, message: 'Successfully clocked out')
      else
        ServiceResult.new(success: false, message: 'Failed to clock out. No ongoing sleep record found.')
      end
    rescue ActiveRecord::RecordNotFound => e
      ServiceResult.new(success: false, message: e.message)
    end

    def get_current(user_id)
      user = User.find(user_id)
      current_record = user.send(:current_sleep_record)
      
      if current_record
        ServiceResult.new(success: true, data: current_record)
      else
        ServiceResult.new(success: false, message: 'No ongoing sleep record found')
      end
    rescue ActiveRecord::RecordNotFound => e
      ServiceResult.new(success: false, message: e.message)
    end

    def get_friends_records(user_id, page: nil, per_page: 20)
      user = User.find(user_id)
      page = page || 1
      per_page = per_page || 20
      
      # Get the ActiveRecord relation and apply pagination
      friends_records_relation = user.friends_sleep_records
      paginated_friends_records = friends_records_relation.page(page).per(per_page)
      
      ServiceResult.new(
        success: true, 
        data: paginated_friends_records,
        meta: {
          current_page: paginated_friends_records.current_page,
          total_pages: paginated_friends_records.total_pages,
          total_count: paginated_friends_records.total_count,
          per_page: per_page.to_i,
          next_page: paginated_friends_records.next_page,
          prev_page: paginated_friends_records.prev_page
        }
      )
    rescue ActiveRecord::RecordNotFound => e
      ServiceResult.new(success: false, message: e.message)
    end

    def destroy(user_id, sleep_record_id)
      user = User.find(user_id)
      sleep_record = SleepRecord.where(user_id: user.id).find(sleep_record_id)
      sleep_record.destroy
      
      ServiceResult.new(success: true, message: 'Sleep record deleted successfully')
    rescue ActiveRecord::RecordNotFound => e
      ServiceResult.new(success: false, message: e.message)
    end
  end
end
