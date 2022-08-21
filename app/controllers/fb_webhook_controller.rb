class FbWebhookController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[ingest]

  def index
    render plain: params["hub.challenge"]
  end

  def ingest
    puts params.inspect
    head :ok
  end
end
