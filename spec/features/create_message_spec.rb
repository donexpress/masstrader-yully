require 'rails_helper'

RSpec.describe 'Create message', type: :feature do
  describe 'Bulk' do
    describe 'when CSV is valid' do
      before(:each) do
        @conversation = build(:conversation)
        @csv_path = 'valid-test.csv'

        CSV.open(@csv_path, "w") do |csv|
          csv << ['phone_number', 'keyword', 'address', 'product title', 'amount']
          csv << [@conversation.client_phone_number, 'keyword', 'Stgo Chile', 'Product', 1000]
        end

        visit new_message_path
      end

      it 'can send a template' do
        attach_file(:message_csv_file, @csv_path)
        click_button 'Create Message'
        expect(page).to have_content('Conversations')
        expect(page).to have_content(@conversation.client_phone_number)
      end
    end
  end
end
