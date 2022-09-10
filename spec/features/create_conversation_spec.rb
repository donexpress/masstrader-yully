require 'rails_helper'

RSpec.describe 'Create conversation', type: :feature do
  before(:each) do
    @conversation = build(:conversation)
    visit new_conversation_path
  end

  scenario 'it succeeds when client phone number is valid' do
    fill_in :conversation_client_phone_number, with: @conversation.client_phone_number
    click_button 'Create Conversation'
    expect(page).to have_content(@conversation.client_phone_number)
  end

  scenario 'it fails when client phone number is invalid' do
    fill_in :conversation_client_phone_number, with: '569'
    click_button 'Create Conversation'
    expect(page).to have_content(@conversation.errors.messages.first)
  end
end
