class Api::V1::BaseController < Api::BaseController

  protected

  # Helper untuk DRY cache logic
  def render_cached_or_fresh(cache_key)
    cached = Rails.cache.read(cache_key)
    if cached
      render json: cached
    else
      data = yield
      Rails.cache.write(cache_key, data, expires_in: 10.minutes) if data.present?
      render json: data if data.present?
    end
  end
end
