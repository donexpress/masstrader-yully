class ShipmentsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_api_token

  def index
    tracking_number = params[:tracking_number]
    if tracking_number.blank?
      render json: {
        status: 400,
        message: 'Bad request',
        data: nil
      }, status: :bad_request
    end

    tracking_number = tracking_number.upcase

    raw_events = RawEvent.where("data ->> 'tracking' = ?", tracking_number)
    parsed_event_data = (raw_events.map do |raw_event|
      begin
        raw_event_hash = raw_event.data
        parsed_event = {}
        parsed_event[:timestamp] = RawEvent.after_threshold?(raw_event_hash['date'], raw_event.id) ? RawEvent.swap_month_day(raw_event_hash['date']) : raw_event_hash['date']
        parsed_event[:tracking_number] = raw_event_hash['tracking'].upcase

        # milestone =
        #   if RawEvent.override_contact_threshold?(raw_event.id) && raw_event_hash['description'].upcase == 'DISPATCHED'
        #     'DELIVERY FAILED'
        #   else
        #     raw_event_hash['description']
        #   end

        milestone = raw_event_hash['description']
        parsed_event[:milestone] = milestone

        location =
          if RawEvent.override_contact_threshold?(parsed_event[:tracking_number], parsed_event[:milestone])
            'Contactar a contacto@easy2go.cl'
          else
            RawEvent.location_from_milestone(raw_event_hash['description'])
          end

        parsed_event[:location] = location
        parsed_event
      rescue StandardError => _e
        nil
      end
    end).compact

    tracking_event_data = parsed_event_data
    if HelpCourierExpress::Shipment.in_subset?(tracking_number)
      tracking_event_data.pop
      other_events = HelpCourierExpress::Scraper.run(tracking_number)
      tracking_event_data.push(other_events.last)
    end

    if tracking_event_data.any?
      render json: {
        status: 200,
        message: 'Ok',
        carrier: 'CL2',
        country: 'CL',
        data: {
          tracking_number:,
          delivered: !!tracking_event_data.find { |e| e[:milestone] == 'Entregado' },
          events: build_events(tracking_event_data)
        }
      }
    else
      render json: {
        status: 404,
        message: 'Not found',
        data: {
          tracking_number:,
          delivered: nil,
          events: nil
        }
      }, status: :not_found
    end
  end

  def verify_api_token
    begin
      authorization_token = request.headers['Authorization'].split('Bearer ').last
      if Rails.env.development?
        dev_value = '1aa92cfc7a2b81f7052608d8bb172838a3b0d2c1aeff618955b12e9cca396baf1178df3f1cc3dc9e653683afed02051a76df9ee2b1a4e1ae74385bc302871362'
        render_unauthorized unless authorization_token == dev_value
      else
        render_unauthorized unless ENV['API_AUTH_TOKEN'] == authorization_token
      end
    rescue StandardError => e
      Rails.logger.error(e.message)
      render_unauthorized
    end
  end

  private

  def build_events(tracking_event_data)
    tracking_event_data
      .map { |e| e.delete(:tracking_number); e }
      .sort_by { |e| DateTime.parse(e[:timestamp]).to_i }
      .map { |e| e[:milestone] = RawEvent.map_milestone(e[:milestone]); e }
  end

  def render_unauthorized
    render json: {
      status: 401,
      message: 'Unauthorized',
      data: nil
    }
  end
end
