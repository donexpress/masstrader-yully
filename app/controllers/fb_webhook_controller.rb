class FbWebhookController < ApplicationController

  def index
    render plain: params["hub.challenge"]
  end

  def ingest
    puts params.inspect
    head :ok
  end
end
