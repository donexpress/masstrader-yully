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
    business_phone_number = ENV.fetch('WA_SENDER_PHONE_NUMBER')

    @conversation_query = Conversation.includes(:messages)
    @conversation_query = @conversation_query.where("business_phone_number = ?", business_phone_number)
    if @q.present?
      @conversation_query = @conversation_query
                  .where('client_phone_number LIKE ?', "%#{@q}%").or(
        Conversation.where(":keywords = ANY (keywords)", keywords: @q))
    end

    # https://bhserna.com/query-date-ranges-rails-active-record.html
    if @date.present?
      start_datetime = DateTime.parse(@date)
      end_datetime = start_datetime.at_end_of_day()
      start_utc_offset = Time.parse(start_datetime.to_date.to_s).in_time_zone('America/Mexico_City').utc_offset
      end_utc_offset = Time.parse(end_datetime.to_date.to_s).in_time_zone('America/Mexico_City').utc_offset
      shifted_start_datetime = start_datetime - start_utc_offset.seconds
      shifted_end_datetime = end_datetime - end_utc_offset.seconds
      Rails.logger.info shifted_start_datetime
      Rails.logger.info shifted_end_datetime
      # puts(@tz)
      if @sort.present? && (@sort == "no_keyword" || @sort == "no_outgoing_messages")
        @conversation_query = @conversation_query.where('latest_message_sent_at BETWEEN ? AND ?', shifted_start_datetime, shifted_end_datetime)
      else
        @conversation_query = @conversation_query.where('latest_outgoing_sent_at BETWEEN ? AND ?', shifted_start_datetime, shifted_end_datetime)
      end
    end
    if(!@sort.present? || @sort == "latest_updated" || @sort == "keyword_desc" || @sort == "keyword_asc")
      defaultFilters()
    elsif @sort.present? && @sort == "no_keyword"
      noKeyword()
    elsif @sort.present? && @sort == "unread_message"
      unreadMessage()
    elsif @sort.present? && @sort == "no_outgoing_messages"
      noOutgoingMessages()
    end
    # @total_count = @conversation_query.count
    @total_count = @count
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

    @template_params = ['', '', '', '']
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
    # date_init = DateTime.parse(date)
    # at_end_of_day = date_init.at_end_of_day()
    @conversation = Conversation.includes(:messages).find(@conversation.id)

    # @conversation.broadcast_replace(locals: { date: date, q: q, tz: @tz, page: page, sort: sort })
    @conversation.broadcast_replace(locals: { date: date, q: q, tz: 'America/Mexico_City', page: page, sort: sort })

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

  def export_excel
    @date = params[:date]
    @sort = params[:sort]
    mark_as_read = params[:mark_as_read]
    if !@date.present?
      start_datetime = DateTime.now
    else 
      start_datetime = DateTime.parse(@date)
    end

    conversation_query = Conversation.includes(:messages)
    business_phone_number = ENV.fetch('WA_SENDER_PHONE_NUMBER')
    conversation_query = conversation_query.where("business_phone_number = ?", business_phone_number)


    end_datetime = start_datetime.at_end_of_day()
    start_utc_offset = Time.parse(start_datetime.to_date.to_s).in_time_zone('America/Mexico_City').utc_offset
    end_utc_offset = Time.parse(end_datetime.to_date.to_s).in_time_zone('America/Mexico_City').utc_offset
    shifted_start_datetime = start_datetime - start_utc_offset.seconds
    shifted_end_datetime = end_datetime - end_utc_offset.seconds
    Rails.logger.info shifted_start_datetime
    Rails.logger.info shifted_end_datetime
    # puts(@tz)
    conversation_query = conversation_query.select("conversations.*")
    if @sort.present? && (@sort == "no_keyword" || @sort == "no_outgoing_messages")
      if @date.present?
        conversation_query = conversation_query.where('latest_message_sent_at BETWEEN ? AND ?', shifted_start_datetime, shifted_end_datetime)
      end
    else
      if @date.present?
        conversation_query = conversation_query.where('latest_outgoing_sent_at BETWEEN ? AND ?', shifted_start_datetime, shifted_end_datetime)
      end
    end
    # conversation_query =
        if @sort == 'keyword_asc' || @sort == 'keyword_desc'          
          unnesting_arr = Conversation.select('distinct on (conversations.id) id', 'unnest(conversations.keywords)')
          unnesting_arr = unnesting_arr.order(Arel.sql("id, unnest DESC NULLS LAST"))
          conversation_query = conversation_query.joins("join (#{unnesting_arr.to_sql}) as c1 on conversations.id = c1.id")
          conversation_query = conversation_query.order(Arel.sql("unnest DESC NULLS LAST"))
        elsif @sort == 'latest_updated'
          conversation_query = conversation_query.order('latest_message_sent_at DESC NULLS LAST')
        end
      if @sort == 'no_keyword'
        conversation_query = conversation_query.where("keywords = '{}'")
        conversation_query = conversation_query.order('id ASC NULLS LAST')

      elsif @sort == 'unread_message'
        conversation_query = conversation_query.joins("join messages as m1 on conversations.id = m1.conversation_id")
        conversation_query = conversation_query.where("read = false and outgoing = false")
      elsif @sort == "no_outgoing_messages"
        conversation_query = conversation_query.where("latest_outgoing_sent_at IS NULL")
        conversation_query = conversation_query.order('id ASC NULLS LAST')
      end
    conversations = conversation_query.all
    final_conversation = []

    if @sort != 'unread_message' && @sort != 'no_keyword'
      conversations = conversations.each do |conversation|
        conversation.keywords = getKeyword(conversation.keywords, conversation.messages)
      end
    end
    conversations.each do |conversation|
      found = false
      final_conversation.each do |final|
        conversation.keywords.each do |c_keyword|
          final.keywords.each do |f_keyword|
            if c_keyword == f_keyword && (@sort != 'no_keyword')
              found = true
            end
          end
        end
      end
      if !found
        final_conversation.append(conversation)
      end
    end
    if @sort == 'keyword_desc' || @sort == 'unread_message'
      final_conversation = final_conversation.sort { |a, b| ((a.present? && a.keywords.present?) ? a.keywords.last : "" )<=> ((b.present? && b.keywords.present?) ? b.keywords.last : "" )} .reverse!
    elsif @sort == 'keyword_asc'
      final_conversation = final_conversation.sort { |a, b| ((a.present? && a.keywords.present?) ? a.keywords.last : "") <=> ((b.present? && b.keywords.present?) ? b.keywords.last : "" )}
    end
    @items = final_conversation
    if mark_as_read
      if !@date.present?
        Message.update_all "read = 'true'"
      else
        messages = Message.where("created_at BETWEEN ? AND ?", shifted_start_datetime, shifted_end_datetime).update_all "read = 'true'"
      end
    end
    respond_to do |format|
      format.xlsx {
        response.headers[
          'Content-Disposition'
        ] = "attachment; filename=conversations-#{@date}.xlsx"
      }
      format.html { render :index }
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

    def getKeyword(keywords, messages)
      key = []
      if @date.present?
        local = DateTime.parse(@date)
      else
        local = DateTime.now
      end
      start_datetime = local
      end_datetime = start_datetime.at_end_of_day()
      start_utc_offset = Time.parse(start_datetime.to_date.to_s).in_time_zone('America/Mexico_City').utc_offset
      end_utc_offset = Time.parse(end_datetime.to_date.to_s).in_time_zone('America/Mexico_City').utc_offset
      shifted_start_datetime = start_datetime - start_utc_offset.seconds
      shifted_end_datetime = end_datetime - end_utc_offset.seconds
      keywords.each do |keyword|
        messages.each do |message|
          if(message.body.start_with?("cod_"))
            cKye = message.body.split(",").last
            if(!@date.present? || cKye == keyword && message.sent_at && shifted_start_datetime < message.sent_at && message.sent_at < shifted_end_datetime)
              found = false
              key.each do |added|
                if(added == keyword)
                  found = true
                end
              end
              if(!found)
                key.append(keyword)
              end
            end
          end
        end
      end
      key
    end

    def checkOrder(previous, current)
      is_correct = false

      previous.keywords.each do |previous_kyword|
        current.keywords.each do |current_keyword|
          if(previous_kyword[0...1] == current_keyword[0...1])
            is_correct = true;
          end
        end
      end
      is_correct
    end

    def ableToAdd(final_conversations, conversation)
      is_able = true;
      final_conversations.each do |previous_conversation|
        previous_conversation.keywords.each do |previous_keyword|
          conversation.keywords.each do |current_keyword|
            if(previous_keyword == current_keyword)
              is_able = false;
            end
          end
        end
      end
      is_able
    end

    def defaultFilters
      @conversation_query = @conversation_query.select("*")
      @conversation_query =
          if @sort == 'keyword_asc' || @sort == 'keyword_desc'
            if @q.present?
              unnesting_arr = Conversation.select('distinct on (conversations.id) id', 'unnest(conversations.keywords)')
              unnesting_arr = unnesting_arr.order(Arel.sql("id, unnest DESC NULLS LAST"))
            else
              unnesting_arr = Conversation.select('conversations.id', 'unnest(conversations.keywords)')
            end
            @conversation_query = @conversation_query.joins("join (#{unnesting_arr.to_sql}) as c1 on conversations.id = c1.id")
            @conversation_query = @conversation_query.order(Arel.sql("unnest DESC NULLS LAST"))
          else
            @conversation_query.order('latest_message_sent_at DESC NULLS LAST')
          end
  
      if(@date.present?)
        conversations = @conversation_query.all
        final_conversation = []
        conversations = conversations.each do |conversation|
          conversation.keywords = getKeyword(conversation.keywords, conversation.messages)
        end
          conversations.each do |conversation|
            found = false
            final_conversation.each do |final|
              conversation.keywords.each do |c_keyword|
                final.keywords.each do |f_keyword|
                  if(c_keyword == f_keyword)
                    found = true
                  end
                end
              end
            end
            if !found
              final_conversation.append(conversation)
            end
          end
        if @sort == 'keyword_desc'
          final_conversation = final_conversation.sort { |a, b| ((a.present? && a.keywords.present?) ? a.keywords.last : "" )<=> ((b.present? && b.keywords.present?) ? b.keywords.last : "" )} .reverse!
        elsif @sort == 'keyword_asc'
          final_conversation = final_conversation.sort { |a, b| ((a.present? && a.keywords.present?) ? a.keywords.last : "") <=> ((b.present? && b.keywords.present?) ? b.keywords.last : "" )}
        end
        page = []
        final_conversation.each_with_index do |conversation, index|
          if(index >= (@page - 1) * @per) && index < ((@page - 1) * @per)+@per
            page.append(conversation)
          end
        end
        @count = final_conversation.size
        @conversations = page
      else
        @conversations = @conversation_query.limit(@per).offset((@page - 1) * @per)
        @count = @conversation_query.count
      end
    end

    def noKeyword
      @conversation_query = @conversation_query.where("keywords = '{}'")
      @conversations = @conversation_query.order('id ASC NULLS LAST')
      @conversations = @conversation_query.limit(@per).offset((@page - 1) * @per).all
      @count = @conversation_query.count
    end
    def unreadMessage
      @conversation_query = @conversation_query.joins("join messages as m1 on conversations.id = m1.conversation_id")
      @conversation_query = @conversation_query.where("read = false and outgoing = false")
      @conversations = @conversation_query.select("distinct conversations.*")
      conversations = @conversation_query.all
      final_conversation = []
      conversations.each do |conversation|
        found = false
        final_conversation.each do |final|
          conversation.keywords.each do |c_keyword|
            final.keywords.each do |f_keyword|
              if(c_keyword == f_keyword)
                found = true
              end
            end
          end
        end
        if !found
          final_conversation.append(conversation)
        end
      end
      final_conversation = final_conversation.sort { |a, b| ((a.present? && a.keywords.present?) ? a.keywords.last : "" )<=> ((b.present? && b.keywords.present?) ? b.keywords.last : "" )} .reverse!
      page = []
      final_conversation.each_with_index do |conversation, index|
        if(index >= (@page - 1) * @per) && index < ((@page - 1) * @per)+@per
          page.append(conversation)
        end
      end
      @count = final_conversation.size
      @conversations = page
    end
    def noOutgoingMessages
      @conversations = @conversation_query.select("distinct conversations.*")
      @conversation_query = @conversation_query.where("latest_outgoing_sent_at IS NULL")
      @conversations = @conversation_query.order('id ASC NULLS LAST')
      conversations = @conversation_query.all
      final_conversation = []
      conversations.each do |conversation|
        found = false
        final_conversation.each do |final|
          conversation.keywords.each do |c_keyword|
            final.keywords.each do |f_keyword|
              if(c_keyword == f_keyword)
                found = true
              end
            end
          end
        end
        if !found
          final_conversation.append(conversation)
        end
      end
      page = []
      final_conversation.each_with_index do |conversation, index|
        if(index >= (@page - 1) * @per) && index < ((@page - 1) * @per)+@per
          page.append(conversation)
        end
      end
      @count = final_conversation.size
      @conversations = page
      # @conversations = @conversation_query.limit(@per).offset((@page - 1) * @per)
      
    end
end
