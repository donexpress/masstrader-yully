# frozen_string_literal: true

# Dispatches messages on the WhatsApp API
class DispatchMessageService
  WA_OUTGOING_PHONE_NUMBER_ID = '108212608656928'

  def initialize(message)
    @message = message
    @message.outgoing = true
  end

  def send
    token = 'EAAPncdI4jmIBALj6apXGyOXjrmsoW5z7ZB8leSgRX0dffsofdTENsdRS1tY3HNNbHPuYYXoka4QJ4ZBrvpQYEO2JVT9IpENRRrYfWSZA8Vw0pBjLeTM2I3n0SdDRUZAZCnG9id98clwVgVjZByOYvKOmwm6qBPyed9LrIWuvi3b28zi4BD8yVFkim50JnVEnmR3EoVvhoXDFjeamBxnQ1P'

    conn = Faraday.new(
      url: 'https://graph.facebook.com/v14.0',
      headers: headers(token)
    )

    json_body = body.to_json
    response = conn.post("/v14.0/#{WA_OUTGOING_PHONE_NUMBER_ID}/messages", json_body)
    response_body = JSON.parse(response.body)
    @message.meta = response_body
    if response.success?
      @message.sent_at = DateTime.now
    else
      @message.dispatch_error = response_body['error']['message']
    end

    @message
  end

  private

  def body
    {
      messaging_product: 'whatsapp',
      recipient_type: 'individual',
      to: @message.conversation.client_phone_number,
      type: 'text',
      text: {
        preview_url: false,
        body: @message.body
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
