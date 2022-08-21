# frozen_string_literal: true

# Dispatches messages on the WhatsApp API
class DispatchMessageService
  WA_OUTGOING_PHONE_NUMBER_ID = '108212608656928'

  def initialize(message)
    @message = message
    @message.outgoing = true
  end

  def send
    token = 'EAAPncdI4jmIBAD841GkJG0erAnySVx5iZAOBqQ8Ab1sXJ95hG3qCkrJuP8mVwtFzlHVCyAZBadQ4ZCVXzBpraFBVux4q55KZCptw6zTvrABeZCfZAw1lknB8sY8L3i0ZAZAwkeu5itUzBkshkdlfOH7n44GGiuivgs6ZBB8OudOwacwWxOoBm6TnWM5yrYHF7J3fZAedHZBK80nmWKtUqrbMKVf'

    conn = Faraday.new(
      url: 'https://graph.facebook.com/v14.0',
      headers: headers(token)
    )

    json_body = body.to_json
    response = conn.post("/v14.0/#{WA_OUTGOING_PHONE_NUMBER_ID}/messages", json_body)
    response_body = JSON.parse(response.body)
    @message.meta = response_body
    unless response.success?
      @message.errors.add(:message, "Could not send message due to #{response_body['error']['message']}")
    end

    @message
  end

  private

  def body
    {
      messaging_product: 'whatsapp',
      recipient_type: 'individual',
      to: @message.receiver_phone_number,
      type: 'text',
      text: {
        preview_url: false,
        body: @message.message
      }

      # type: 'template',
      # template: {
      #   name: 'hello_world',
      #   language: {
      #     code: 'en_US'
      #   }
      # }
    }
  end

  def headers(token)
    {
      'Content-Type': 'application/json',
      Authorization: "Bearer #{token}"
    }
  end
end
