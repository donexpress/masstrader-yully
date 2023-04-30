FactoryBot.define do
  factory :conversation do
    business_phone_number { Conversation::WA_SENDER_PHONE_NUMBER }
    client_phone_number { "60#{rand(11111111..99999999)}"}
  end
end
