class ApplicationController < ActionController::Base
  before_action :retrieve_tz_from_cookies

  private

  def retrieve_tz_from_cookies
    @tz = cookies['browser-tz']
  end
end
