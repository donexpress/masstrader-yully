class ConversationsController < ApplicationController
  before_action :set_conversation, only: %i[ show edit update destroy read ]
  after_action :read_unread_messages, only: %i[ show ]

  # GET /conversations or /conversations.json
  def index
    @page = params[:page].to_i > 0 ? params[:page].to_i : 1
    @per = 20
    @q = params[:q]
    @date = params[:date]
    @sort = params[:sort]

    conversation_query = Conversation.includes(:messages)
    if @q.present?
      conversation_query = conversation_query
                  .where('client_phone_number LIKE ?', "%#{@q}%").or(
        Conversation.where(":keywords = ANY (keywords)", keywords: @q))
    end

    # https://bhserna.com/query-date-ranges-rails-active-record.html
    if @date.present?
      start_datetime = DateTime.parse(@date)
      end_datetime = start_datetime.at_end_of_day()
      start_utc_offset = Time.parse(start_datetime.to_date.to_s).in_time_zone(@tz).utc_offset
      end_utc_offset = Time.parse(end_datetime.to_date.to_s).in_time_zone(@tz).utc_offset
      shifted_start_datetime = start_datetime - start_utc_offset.seconds
      shifted_end_datetime = end_datetime - end_utc_offset.seconds
      Rails.logger.info shifted_start_datetime
      Rails.logger.info shifted_end_datetime
      conversation_query = conversation_query.where('latest_message_sent_at BETWEEN ? AND ?', shifted_start_datetime, shifted_end_datetime)
    end
      conversation_query =
        if @sort == 'keyword_asc'
          unnesting_arr = Conversation.select('distinct on(conversations.id) id', 'unnest(conversations.keywords)')
          unnesting_arr = unnesting_arr.order(Arel.sql("id, unnest ASC"))
          conversation_query = conversation_query.joins("join (#{unnesting_arr.to_sql}) as c1 on conversations.id = c1.id")
          conversation_query = conversation_query.select("*")
          conversation_query.order(Arel.sql("unnest ASC NULLS LAST"))
        elsif @sort == 'keyword_desc'
          unnesting_arr = Conversation.select('distinct on(conversations.id) id', 'unnest(conversations.keywords)')
          unnesting_arr = unnesting_arr.order(Arel.sql("id, unnest DESC"))
          conversation_query = conversation_query.joins("join (#{unnesting_arr.to_sql}) as c1 on conversations.id = c1.id")
          conversation_query = conversation_query.select("*")
          conversation_query.order(Arel.sql("unnest DESC NULLS LAST"))
        else
          conversation_query.order('latest_message_sent_at DESC NULLS LAST')
        end

    
    @conversations = conversation_query.limit(@per).offset((@page - 1) * @per)
    @total_count = conversation_query.count
    @page_count = (@total_count / @per) + 1
  end

  # GET /conversations/1 or /conversations/1.json
  def show
    @date = params[:date]
    @q = params[:q]
    @page = params[:page]
    @sort = params[:sort]
    @bulk_insert = params[:bulk] == 'true'
    @message = @conversation.messages.build
    @message_type = @conversation.messages.size.zero? ? Message::TEMPLATE_TYPE : Message::TEXT_TYPE

    @template_params = ['', '', '', '', '']
  end

  # GET /conversations/new
  def new
    @conversation = Conversation.new
  end

  # GET /conversations/1/edit
  def edit
  end

  # POST /conversations or /conversations.json
  def create
    @conversation = Conversation.new(conversation_params)

    respond_to do |format|
      if @conversation.save
        format.html { redirect_to conversation_url(@conversation), notice: "Conversation was successfully created." }
        format.json { render :show, status: :created, location: @conversation }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @conversation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /conversations/1 or /conversations/1.json
  def update
    respond_to do |format|
      if @conversation.update(conversation_params)
        format.html { redirect_to conversation_url(@conversation), notice: "Conversation was successfully updated." }
        format.json { render :show, status: :ok, location: @conversation }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @conversation.errors, status: :unprocessable_entity }
      end
    end
  end

  def read
    unread_messages = @conversation.messages.select(&:unread?)
    Message.where(id: unread_messages.map(&:id)).update_all(read: true)
    url_params = CGI.parse(URI.parse(request.referrer).query || '')
    date = url_params['date'].is_a?(Array) ? url_params['date']&.first : url_params['date']
    q = url_params['q'].is_a?(Array) ? url_params['q']&.first : url_params['q']
    sort = url_params['sort'].is_a?(Array) ? url_params['sort']&.first : url_params['sort']
    page = url_params['page'].is_a?(Array) ? url_params['page']&.first : url_params['page']
    # we grab the messages from the db again
    # so that the view can be refreshed correctly
    date_init = DateTime.parse(date)
    at_end_of_day = date_init.at_end_of_day()
    @conversation = Conversation.includes(:messages).find(@conversation.id)

    @conversation.broadcast_replace(locals: { date: date, q: q, tz: @tz, page: page, sort: sort })

    head :ok
  end

  # DELETE /conversations/1 or /conversations/1.json
  def destroy
    @conversation.destroy

    respond_to do |format|
      format.html { redirect_to conversations_url, notice: "Conversation was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_conversation
      @conversation = Conversation.includes(:messages).find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def conversation_params
      params.require(:conversation).permit(:client_phone_number, :business_phone_number)
    end

    def read_unread_messages
      messages = @conversation.messages.reject(&:read)
      messages.each do |message|
        message.update(read: true)
      end
    end
end
