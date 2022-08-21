require "test_helper"

class FbEventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @fb_event = fb_events(:one)
  end

  test "should get index" do
    get fb_events_url
    assert_response :success
  end

  test "should get new" do
    get new_fb_event_url
    assert_response :success
  end

  test "should create fb_event" do
    assert_difference("FbEvent.count") do
      post fb_events_url, params: { fb_event: { data: @fb_event.data } }
    end

    assert_redirected_to fb_event_url(FbEvent.last)
  end

  test "should show fb_event" do
    get fb_event_url(@fb_event)
    assert_response :success
  end

  test "should get edit" do
    get edit_fb_event_url(@fb_event)
    assert_response :success
  end

  test "should update fb_event" do
    patch fb_event_url(@fb_event), params: { fb_event: { data: @fb_event.data } }
    assert_redirected_to fb_event_url(@fb_event)
  end

  test "should destroy fb_event" do
    assert_difference("FbEvent.count", -1) do
      delete fb_event_url(@fb_event)
    end

    assert_redirected_to fb_events_url
  end
end
