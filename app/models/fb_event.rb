class FbEvent < ApplicationRecord
  validates :data, presence: true

  def message_delivered?
    data['entry'].first['changes'].first['value']['statuses'].first['status'] == 'delivered' rescue false
  end

  def message_sent?
    data['entry'].first['changes'].first['value']['statuses'].first['status'] == 'sent' rescue false
  end
end
