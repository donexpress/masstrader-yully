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

  scenario 'Can search for conversations' do
    conversation = create(:conversation)
    create(:message, conversation: conversation, outgoing: true)
    visit conversations_path
    fill_in :q, with: conversation.client_phone_number.reverse.slice(0, 4).reverse
    click_button 'Search'
    expect(page).to have_content('Conversations')
    expect(page).to have_content(conversation.client_phone_number)
    fill_in :q, with: ''
    fill_in :date, with: conversation.created_at.to_date.to_s
    click_button 'Search'
    expect(page).to have_content('Conversations')
    expect(page).to have_content(conversation.client_phone_number)
  end

  scenario 'Can navigate to a specific conversation and revisit the index page' do
  end
end
