# frozen_string_literal: true

# Saves a message for every successful outgoing message
# via the WA Business API
class Message < ApplicationRecord
  belongs_to :conversation

  validates :message, presence: true
  validates :meta, presence: true
  validates :outgoing, inclusion: { in: [true, false] }

end
