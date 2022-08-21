json.extract! message, :id, :receiver_phone_number, :message, :sender_phone_number, :meta, :outgoing, :created_at, :updated_at
json.url message_url(message, format: :json)
