require 'rails_helper'

RSpec.describe 'Index conversations', type: :feature do
  scenario 'No conversations' do
    visit conversations_path
    expect(page).to have_content('Conversations')
  end

  scenario 'At least one conversation' do
    conversation = create(:conversation)
    visit conversations_path
    expect(page).to have_content('Conversations')
    expect(page).to have_content(conversation.client_phone_number)
  end
end
