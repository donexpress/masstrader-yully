FactoryBot.define do
  factory :message do
    conversation
    body { 'This is the body' }
    meta { { hello: :world } }
    outgoing { [true, false].sample }
  end
end
