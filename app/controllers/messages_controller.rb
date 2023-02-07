class MessagesController < ApplicationController
  before_action :set_message, only: %i[ show edit update destroy ]
  before_action :assign_new_message_vars, only: %i[ new  create ]

  # GET /messages or /messages.json
  def index
    @messages = Message.all
  end

  # GET /messages/1 or /messages/1.json
  def show
  end

  # GET /messages/new
  def new
  end

  # GET /messages/1/edit
  def edit
  end

  # POST /messages or /messages.json
  def create
    @message_type = message_params[:message_type]

    csv_file = params[:message][:csv_file]
    if csv_file.present?
      begin
        csv_rows = CSV.read(csv_file)
      rescue StandardError => e
        Rails.logger.error(e.message)
        flash[:error] = e.message

        return respond_to do |format|
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: { error: e.message }, status: :unprocessable_entity }
        end
      end
      csv_rows.shift # remove headers - unorthodox but whatever
      @messages = Message.new(message_params).from_csv_rows(csv_rows)
      bulk_create
    else
      single_create
    end
  end

  # PATCH/PUT /messages/1 or /messages/1.json
  def update
    respond_to do |format|
      if @message.update(message_params)
        format.html { redirect_to message_url(@message), notice: "Message was successfully updated." }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1 or /messages/1.json
  def destroy
    @message.destroy

    respond_to do |format|
      format.html { redirect_to messages_url, notice: "Message was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

    def single_create
      @message = Message.new(message_params)
      @conversation = Conversation.find(message_params[:conversation_id])
      @template_params = message_params[:template_params].values

      if @message.body.blank? && @template_params.any? { |v| v.present? }
        @message.body = "cod_alert_template #{@template_params.join(',')}"
      end

      url_params = CGI.parse(URI.parse(request.referrer || '').query || '')
      @date = url_params['date'].is_a?(Array) ? url_params['date']&.first : url_params['date']
      @q = url_params['q'].is_a?(Array) ? url_params['q']&.first : url_params['q']
      @sort = url_params['sort'].is_a?(Array) ? url_params['sort']&.first : url_params['sort']
      @page = url_params['page'].is_a?(Array) ? url_params['page']&.first : url_params['page']

      respond_to do |format|
        dms = DispatchMessageService.new(@message)
        @message = dms.send

        if @message.save
          if !@conversation.keywords.include?(@template_params.last)
            @conversation.keywords.push(@template_params.last)
            @conversation.save
          end

          format.html { redirect_to conversation_url(@message.conversation, date: @date, q: @q, sort: @sort, page: @page), notice: "Message was successfully created." }
          format.json { render :show, status: :created, location: @message }
        else
          format.html { render 'conversations/show', status: :unprocessable_entity }
          format.json { render json: @message.errors, status: :unprocessable_entity }
        end
      end
    end

    def bulk_create
      # we discard invalid messages for now
      messages = @messages
      messages.each do |message|
        # can improve this as
        conversation = Conversation.find_by(client_phone_number: message.client_phone_number)
        if conversation.nil?
          new_conversation = Conversation.new(client_phone_number: message.client_phone_number)
          if new_conversation.save
            # skip because it would mean that the phone number is invalid
            conversation = new_conversation
          else
            next
          end
        end

        keyword = message.keyword_string
        if !conversation.keywords.include?(keyword)
          conversation.keywords.push(keyword)
          conversation.save!
        end

        message.conversation = conversation
      end

      # may want to join these two each blocks
      # for now if conversation is nil
      # we next inside this loop as well
      messages.each do |message|
        next if message.conversation.nil?

        if message.body.blank?
          message.body = "cod_alert_template #{message.template_params.values.join(',')}"
        end

        sleep 0.05
        dms = DispatchMessageService.new(message)
        message = dms.send
        message.save
      end

      # refactor candidate

      # if valid_csv?
      respond_to do |format|
        format.html { redirect_to conversations_url, notice: "Messages were successfully created." }
        format.json { render :show, status: :created, location: @message }
      end
      # else
      #   format.html { render 'conversations/show', status: :unprocessable_entity }
      #   format.json { render json: @message.errors, status: :unprocessable_entity }
      # end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def message_params
      params.require(:message).permit(:body, :conversation_id, :message_type, :csv_file, template_params: {}).except(:csv_file)
    end

    def assign_new_message_vars
      @message = Message.new
      @message_type = Message::TEMPLATE_TYPE
      @template_params = ['', '', '', '', '']

      url_params = CGI.parse(URI.parse(request.referrer || '').query || '')
      @date = url_params['date'].is_a?(Array) ? url_params['date']&.first : url_params['date']
      @q = url_params['q'].is_a?(Array) ? url_params['q']&.first : url_params['q']
      @sort = url_params['sort'].is_a?(Array) ? url_params['sort']&.first : url_params['sort']
      @page = url_params['page'].is_a?(Array) ? url_params['page']&.first : url_params['page']
    end
end
