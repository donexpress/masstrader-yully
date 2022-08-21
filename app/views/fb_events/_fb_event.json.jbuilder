json.extract! fb_event, :id, :data, :created_at, :updated_at
json.url fb_event_url(fb_event, format: :json)
