class FbWebhookController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[ingest]

  def index
    render plain: params['hub.challenge']
  end

  def ingest
    event = params[:fb_webhook]
    FbEvent.create!(data: event.permit!.to_h)

    messages, client_phone_number = ReceiveMessageService.new(event).process
    conversation = Conversation.find_by(client_phone_number: client_phone_number)

    if conversation.nil?
      conversation = Conversation.create!(client_phone_number: client_phone_number)
    end

    messages.each do |message|
      message.conversation_id = conversation.id
      message.save!
    end

    head :ok
  end
end
