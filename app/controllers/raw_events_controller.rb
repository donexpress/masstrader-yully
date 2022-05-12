class RawEventsController < ApplicationController
  def create
    raw_event = RawEvent.create!(data: params.permit!.to_h)
    render json: raw_event, status: :created
  end

  def ingest
    RawEvent.create!(data: params.permit!.to_h)
    head :ok
  end
end
