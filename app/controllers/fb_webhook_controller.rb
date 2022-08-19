class FbWebhookController < ApplicationController

  def index

    puts params.inspect
    head :ok
  end
end
