require "application_system_test_case"

class FbEventsTest < ApplicationSystemTestCase
  setup do
    @fb_event = fb_events(:one)
  end

  test "visiting the index" do
    visit fb_events_url
    assert_selector "h1", text: "Fb events"
  end

  test "should create fb event" do
    visit fb_events_url
    click_on "New fb event"

    fill_in "Data", with: @fb_event.data
    click_on "Create Fb event"

    assert_text "Fb event was successfully created"
    click_on "Back"
  end

  test "should update Fb event" do
    visit fb_event_url(@fb_event)
    click_on "Edit this fb event", match: :first

    fill_in "Data", with: @fb_event.data
    click_on "Update Fb event"

    assert_text "Fb event was successfully updated"
    click_on "Back"
  end

  test "should destroy Fb event" do
    visit fb_event_url(@fb_event)
    click_on "Destroy this fb event", match: :first

    assert_text "Fb event was successfully destroyed"
  end
end
