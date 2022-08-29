class FbEvent < ApplicationRecord
  validates :data, presence: true

  def incoming_message_event?
    data['entry'].first['changes'].first['value']['messages'].present? rescue false
  end

  def message_delivered_event?
    data['entry'].first['changes'].first['value']['statuses'].first['status'] == 'delivered' rescue false
  end

  def delivered_at_ts
    Time.at(data['entry'].first['changes'].first['value']['statuses'].first['timestamp'].to_i) rescue nil
  end

  def message_sent_event?
    data['entry'].first['changes'].first['value']['statuses'].first['status'] == 'sent' rescue false
  end

  def sent_at_ts
    Time.at(data['entry'].first['changes'].first['value']['statuses'].first['timestamp'].to_i) rescue nil
  end

  def wa_id
    value = data['entry'].first['changes'].first['value']
    wa_id = value['messages'].first['id'] rescue nil
    if wa_id.nil?
      value['statuses'].first['id'] rescue nil 
    else
      wa_id
    end
  end
end
