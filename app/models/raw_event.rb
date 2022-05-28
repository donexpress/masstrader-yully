class RawEvent < ApplicationRecord
  validates :data, presence: true

  def self.to_csv
    attributes = %w[date office tracking description]

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.find_each do |raw_event|
        csv << attributes.map do |attr|
          if attr == 'description'
            next RawEvent.map_milestone(raw_event.data[attr])
          end

          if attr == 'date'
            if RawEvent.after_threshold?(raw_event.data[attr], raw_event.id)
              next RawEvent.swap_month_day(raw_event.data[attr])
            else
              next raw_event.data[attr]
            end
          end

          if raw_event.data[attr].downcase == 'e2go'
            'CL2'
          else
            raw_event.data[attr]
          end
        end
      end
    end
  end

  def self.after_threshold?(ts_str, id)
    return false if id > 621

    threshold_dt = DateTime.parse("2022-05-25")
    DateTime.parse(ts_str).after? threshold_dt
  end

  def self.swap_month_day(ts_str)
    month = ts_str[5..6]
    day = ts_str[8..9]
    ts_str[0..4] + day + "-" + month + ts_str[10..]
  end

  def self.map_milestone(milestone)
    if milestone.upcase == 'RECEIVED'
      return 'RECEIVED BY DISTRIBUTOR'
    end

    if milestone.upcase == 'ASSIGNED'
      return 'ASSIGNED LAST MILE DELIVERY'
    end

    if milestone.upcase == 'NOT AVAILABLE'
      return 'The package was not received by distributor (not available)'.upcase
    end

    if milestone.upcase == 'REFUSED'
      return 'The package cannot be delivered'.upcase
    end

    milestone
  end
end
