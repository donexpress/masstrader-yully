class ApplicationController < ActionController::Base
  add_flash_types :info, :error, :warning
  before_action :retrieve_tz_from_cookies

  private

  def retrieve_tz_from_cookies
    @tz = cookies['browser-tz'] || 'UTC'
  end
end
