class FbWebhookController < ApplicationController

  def index
    render plain: params["hub.challenge"]
  end
end
