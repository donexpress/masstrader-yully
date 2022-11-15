require 'rails_helper'

RSpec.describe 'Create conversation', type: :feature do
  scenario 'it can read a conversation that has unread messages' do
    conversation = create(:conversation)
    create(:message, conversation: conversation, outgoing: false)
    conversation.reload
    expect(conversation.unread_messages?).to eq true
    visit conversations_path
    expect(page).to have_content('New messages (1)')
    click_button 'Mark as Read'
  end

  scenario 'no button is presented when there are no unread messages' do
    conversation = create(:conversation)
    create(:message, conversation: conversation, outgoing: true)
    conversation.reload
    expect(conversation.unread_messages?).to eq false
    visit conversations_path
    expect(page).not_to have_content('New messages (1)')
  end
end
