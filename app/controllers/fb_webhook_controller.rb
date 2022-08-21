class FbWebhookController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[ingest]

  def index
    render plain: params['hub.challenge']
  end

  def ingest
    event = params[:fb_webhook]
    FbEvent.create!(data: event.permit!.to_h)

    messages = ReceiveMessageService.new(event).process
    messages.each(&:save!)

    head :ok
  end
end
