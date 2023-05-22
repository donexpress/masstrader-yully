class FbWebhookController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[ingest]

  def index
    render plain: params['hub.challenge']
  end

  def ingest
    event = params[:fb_webhook]
    begin
      fb_event = FbEvent.create!(data: event.permit!.to_h)
      if fb_event.incoming_message_event?
        puts event
        messages, client_phone_number = ReceiveMessageService.new(event).process
        conversation = Conversation.find_by(client_phone_number:)

        if conversation.nil?
          conversation = Conversation.create!(client_phone_number:)
        end

        messages.each do |message|
          message.conversation_id = conversation.id
          message.save!
        end
      elsif fb_event.message_delivered_event?
        Message.find_by(wa_id: fb_event.wa_id)&.update(delivered_at: fb_event.delivered_at_ts)
      elsif fb_event.message_sent_event?
        Message.find_by(wa_id: fb_event.wa_id)&.update(sent_at: fb_event.sent_at_ts)
      end

      head :ok
    rescue StandardError => e
      Rails.logger.error(e.backtrace)
      head :ok
    end
  end
end
