class RawEvent < ApplicationRecord
  validates :data, presence: true

  def self.to_csv
    attributes = %w[date office tracking description]

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.find_each do |raw_event|
        csv << attributes.map{ |attr| raw_event.data[attr] }
      end
    end
  end
end
