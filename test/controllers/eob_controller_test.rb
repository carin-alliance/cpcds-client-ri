require 'test_helper'

class EobControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get eob_index_url
    assert_response :success
  end

  test "should get show" do
    get eob_show_url
    assert_response :success
  end

end
