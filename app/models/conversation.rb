class Conversation < ApplicationRecord
  # https://dev.to/kputra/rails-postgresql-array-1jn0
  WA_SENDER_PHONE_NUMBER = ENV.fetch('WA_SENDER_PHONE_NUMBER')

  include PhoneNumber
  extend PhoneNumber

  validates :client_phone_number, presence: true
  validates :business_phone_number, presence: true
  validate :check_client_phone_number

  validates_uniqueness_of :client_phone_number, scope: :business_phone_number
  has_many :messages, -> { order(id: :asc) }, dependent: :destroy

  after_initialize :initialize_callback

  before_validation :clean_client_phone_number, on: :create

  def clean_client_phone_number
    self.client_phone_number = sanitize_and_localize_phone_number(client_phone_number)
  end

  def unread_messages?
    !messages.reject(&:outgoing).all?(&:read)
  end

  def self.sync_keywords_with_phone_number
    rows = CSV.read('phone_number_keywords.csv')
    rows.shift
    rows.each do |row|
      keyword, raw_phone_number = row
      client_phone_number = sanitize_and_localize_phone_number(raw_phone_number)
      conversation = Conversation.find_by(client_phone_number: client_phone_number)

      if conversation.present? && !conversation.keywords.include?(keyword)
        conversation.keywords << keyword
        conversation.save
      end
    end
  end

  private

  def initialize_callback
    self.business_phone_number = WA_SENDER_PHONE_NUMBER
  end

  def check_client_phone_number
    return if client_phone_number.nil?

    if client_phone_number.start_with?('60')
      if clean_client_phone_number.length != 12 && clean_client_phone_number.length != 11
        errors.add(:client_phone_number, 'Malaysian numbers require 10-digits followed after the country code and mobile fixed digit')
      end
    elsif client_phone_number.starts_with?('86')
      if client_phone_number.length != 13
        errors.add(:client_phone_number, 'Cannot send message to this number. Check for the correct country code.')
      end
    else
      errors.add(:client_phone_number, 'Invalid phone number')
    end
  end
end
