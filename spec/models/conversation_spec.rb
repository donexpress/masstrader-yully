require 'rails_helper'

RSpec.describe Conversation, type: :model do
  describe 'factories' do
    it 'works' do
      conversation = create(:conversation)
      expect(conversation.business_phone_number).to be_a(String)
      expect(conversation.client_phone_number).to be_a(String)
    end
  end
end
