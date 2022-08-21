# frozen_string_literal: true

# Saves a message for every successful outgoing message
# via the WA Business API
class OutgoingMessage < ApplicationRecord
  WA_SENDER_PHONE_NUMBER = '56959261264'

  validates :receiver_phone_number, presence: true
  validates :sender_phone_number, presence: true
  validates :message, presence: true
  validates :meta, presence: true
  validates :outgoing, inclusion: { in: [true, false] }

  after_initialize :initialize_callback

  private

  def initialize_callback
    self.sender_phone_number = WA_SENDER_PHONE_NUMBER
  end
end
