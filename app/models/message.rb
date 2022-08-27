# frozen_string_literal: true

# Saves a message for every successful outgoing message
# via the WA Business API
class Message < ApplicationRecord
  belongs_to :conversation

  TEXT_TYPE = 'text'
  TEMPLATE_TYPE = 'template'

  BODY_TYPES = [
    TEXT_TYPE,
    TEMPLATE_TYPE
  ].freeze

  validates :body, presence: true
  validates :meta, presence: true
  validates :outgoing, inclusion: { in: [true, false] }

  attribute :dispatch_error, :string, default: nil
  attribute :message_type, :string, default: TEMPLATE_TYPE
  attribute :template_params, :json, default: {}

  validate :no_dispatch_error
  validate :validate_message_type_and_template_params

  after_create :update_conversation_timestamp

  private

  def no_dispatch_error
    return if dispatch_error.nil?

    errors.add(:dispatch_error, "Facebook API dispatch error: #{dispatch_error}")
  end

  def validate_message_type_and_template_params
    if message_type.blank?
      errors.add(:message_type, 'cannot be blank')
    elsif message_type == TEXT_TYPE
      # do something here
    elsif message_type == TEMPLATE_TYPE
      if template_params.values.any?(&:blank?)
        errors.add(:message, 'must fill in all template params.')
      end
    else
      errors.add(:message_type, 'Invalid message type')
    end
  end

  def update_conversation_timestamp
    conversation.update_column(:latest_message_sent_at, DateTime.now)
  end
end
