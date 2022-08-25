# frozen_string_literal: true

# Saves a message for every successful outgoing message
# via the WA Business API
class Message < ApplicationRecord
  belongs_to :conversation

  validates :body, presence: true
  validates :meta, presence: true
  validates :outgoing, inclusion: { in: [true, false] }

  attribute :dispatch_error, :string, default: nil

  validate :no_dispatch_error

  after_create :update_conversation_timestamp

  def no_dispatch_error
    return if dispatch_error.nil?

    errors.add(:dispatch_error, "Facebook API dispatch error: #{dispatch_error}")
  end

  def update_conversation_timestamp
    conversation.update_column(:latest_message_sent_at, DateTime.now)
  end
end
