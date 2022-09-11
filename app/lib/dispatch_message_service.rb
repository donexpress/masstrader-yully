# frozen_string_literal: true

# Dispatches messages on the WhatsApp API
class DispatchMessageService
  WA_OUTGOING_PHONE_NUMBER_ID = '108212608656928'

  def initialize(message)
    @message = message
    @message.outgoing = true
  end

  def send
    if Rails.env.test?
      @message.meta = { foo: 'bar' }
      @message.dispatched_at = DateTime.now
      @message.wa_id = SecureRandom.hex
    end

    token = 'EAAPncdI4jmIBAB5xj3ydbgeN1QEFaK7OZAk5vV4PRaz3sZBEy8f6VfhEHs6loSlHIUqBrehFuA04PIyek0lt3ZCjzHvvhAK9wZAK50G85poOImGJOZAY52y4joKO3aWq0cs2vXmqwT9rqjJ0insYsdcWM1DFFxIhcsk9anZCZCGQpN33bao4yGh2eJcPmUZB6fZBRynE4BqY8koRXlslZAtaZBO'

    conn = Faraday.new(
      url: 'https://graph.facebook.com/v14.0',
      headers: headers(token)
    )

    json_body = body.to_json
    response = conn.post("/v14.0/#{WA_OUTGOING_PHONE_NUMBER_ID}/messages", json_body)
    response_body = JSON.parse(response.body)
    @message.meta = response_body
    if response.success?
      @message.dispatched_at = DateTime.now
      @message.wa_id = @message.meta_wa_id
    else
      @message.dispatch_error = response_body['error']['message']
    end

    @message
  end

  private

  def generate_template_params
    @message.template_params.values.map do |element|
      {
        type: 'text',
        text: element
      }
    end
  end

  def body
    base_params = {
      messaging_product: 'whatsapp',
      recipient_type: 'individual',
      to: @message.conversation.client_phone_number,
    }

    if @message.message_type == Message::TEMPLATE_TYPE
      base_params.merge({
        type: 'template',
        template: {
          name: 'cod_alert',
          language: {
            code: 'es',
          },
          components: [{
            type: "body",
            parameters: generate_template_params
          }]
        }
      })
    else
      base_params.merge({
        type: 'text',
        text: {
          preview_url: false,
          body: @message.body
        }
      })
    end

  end

  def headers(token)
    {
      'Content-Type': 'application/json',
      Authorization: "Bearer #{token}"
    }
  end
end
