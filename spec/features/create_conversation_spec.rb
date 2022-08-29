require 'rails_helper'

RSpec.describe 'Create conversation', type: :feature do
  before(:each) do
    visit new_conversation_path
  end
end
