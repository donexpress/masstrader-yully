# frozen_string_literal: true

require 'mechanize'

class HelpCourierExpress::Scraper
  def self.run(tracking_number)
    url = "https://helpbankencomiendas.owlchile.cl/api/rastreo?code=#{tracking_number}"

    agent = Mechanize.new
    agent.user_agent_alias = 'Mac Safari'

    page = agent.get url

    data = page.search('#trackingModal > table:nth-of-type(2)')
    raw_event_hash_list = Hash.from_xml(data.to_xml)['table']['tbody']['tr']
      .map { |tr| tr['td'] }
      .map do |row_elements_list|
        {
          timestamp: row_elements_list.first,
          milestone: row_elements_list[3]
        }
      end

    xform_events(raw_event_hash_list)
  end

  def self.xform_events(raw_event_hash_list)
    raw_event_hash_list.map do |raw_event_hash|
      raw_timestamp = raw_event_hash[:timestamp]
      date, time = raw_timestamp.split(' ')
      day, month, year = date.split('/')

      timestamp = "#{year}-#{month}-#{day} #{time}"

      {
        timestamp:,
        milestone: raw_event_hash[:milestone]
      }
    end
  end
end
