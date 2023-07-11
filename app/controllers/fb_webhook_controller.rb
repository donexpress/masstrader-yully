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
        if !client_phone_number.start_with?("600") && client_phone_number.start_with?("60")
          conversation = Conversation.find_by(client_phone_number:)
          if conversation.nil?
            client_phone_number_change = client_phone_number.insert(2, '0')
            conversation1 = Conversation.find_by(client_phone_number: client_phone_number_change)
            if !conversation1.nil?
              client_phone_number = client_phone_number_change
            end
          end

        end
        conversation = Conversation.find_by(client_phone_number:)

        if conversation.nil? && event["entry"].first["changes"].first["value"]["metadata"]["display_phone_number"] == ENV.fetch('WA_SENDER_PHONE_NUMBER')
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
