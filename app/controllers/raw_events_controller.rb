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
    raw_events = RawEvent.all
    send_data raw_events.to_csv, filename: "raw_events-#{Time.now}.csv"
  end
end
