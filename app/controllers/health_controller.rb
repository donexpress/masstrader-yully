class HealthController < ApplicationController

  def index
    render plain: 'Systems online!'
  end
end
