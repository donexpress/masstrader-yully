class ConversationsController < ApplicationController
  before_action :set_conversation, only: %i[ show edit update destroy ]
  after_action :read_unread_messages, only: %i[ show ]

  # GET /conversations or /conversations.json
  def index
    @q = params[:q]

    @conversations =
      if @q.blank?
        Conversation.includes(:messages).all.order(latest_message_sent_at: :desc)
      else
        Conversation.includes(:messages).where('client_phone_number LIKE ?', "%#{@q}%").order(latest_message_sent_at: :desc)
      end

    @conversations
  end

  # GET /conversations/1 or /conversations/1.json
  def show
    @message = @conversation.messages.build
    @message_type = @conversation.messages.size.zero? ? Message::TEMPLATE_TYPE : Message::TEXT_TYPE

    @template_params = ['', '', '']
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
