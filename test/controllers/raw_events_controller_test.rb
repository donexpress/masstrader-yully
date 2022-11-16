require "test_helper"

class RawEventsControllerTest < ActionDispatch::IntegrationTest
  test "can post data" do
    assert_equal(RawEvent.count, 0)
    post raw_events_path, params: { hello: 'world' }
    assert_response :created
    assert_equal(RawEvent.count, 1)
  end

  test "can post on /ingest" do
    assert_equal(RawEvent.count, 0)
    post ingest_raw_events_path, params: { hello: 'world' }
    assert_response :success
    assert_equal(RawEvent.count, 1)
  end
end
