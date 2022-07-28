class RawEventsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    render json: RawEvent.all
  end

  def create
    raw_event = RawEvent.create!(data: params.permit!.to_h)
    render json: raw_event, status: :created
  end

  def ingest
    RawEvent.create!(data: params.permit!.to_h)
    head :ok
  end

  def dump
    current_time_str = Time.now.utc.strftime '%Y%m%d%H%M%S'
    send_data RawEvent.to_csv(filter: params[:filter]), filename: "raw_events-#{current_time_str}.csv"
  end
end
