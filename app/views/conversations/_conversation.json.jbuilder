json.extract! conversation, :id, :client_phone_number, :business_phone_number, :created_at, :updated_at
json.url conversation_url(conversation, format: :json)
