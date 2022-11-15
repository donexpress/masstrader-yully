require 'rails_helper'

RSpec.describe Message, type: :model do
  describe 'factories' do
    it 'works' do
      message = create(:message)
      expect(message.body).to be_a(String)
      expect(message.meta).to be_a(Hash)
      expect([true, false].include?(message.outgoing)).to eq true
    end
  end
end
