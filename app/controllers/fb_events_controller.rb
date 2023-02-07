class FbEventsController < ApplicationController
  before_action :set_fb_event, only: %i[ show edit update destroy ]

  # GET /fb_events or /fb_events.json
  def index
    @fb_events = FbEvent.all.order(id: :desc)
  end

  # GET /fb_events/1 or /fb_events/1.json
  def show
  end

  # GET /fb_events/new
  def new
    @fb_event = FbEvent.new
  end

  # GET /fb_events/1/edit
  def edit
  end

  # POST /fb_events or /fb_events.json
  def create
    @fb_event = FbEvent.new(fb_event_params)

    respond_to do |format|
      if @fb_event.save
        format.html { redirect_to fb_event_url(@fb_event), notice: "Fb event was successfully created." }
        format.json { render :show, status: :created, location: @fb_event }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @fb_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /fb_events/1 or /fb_events/1.json
  def update
    respond_to do |format|
      if @fb_event.update(fb_event_params)
        format.html { redirect_to fb_event_url(@fb_event), notice: "Fb event was successfully updated." }
        format.json { render :show, status: :ok, location: @fb_event }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @fb_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fb_events/1 or /fb_events/1.json
  def destroy
    @fb_event.destroy

    respond_to do |format|
      format.html { redirect_to fb_events_url, notice: "Fb event was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fb_event
      @fb_event = FbEvent.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def fb_event_params
      params.require(:fb_event).permit(:data)
    end
end
