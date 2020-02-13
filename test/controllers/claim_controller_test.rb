require 'test_helper'

class ClaimControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get claim_index_url
    assert_response :success
  end

  test "should get show" do
    get claim_show_url
    assert_response :success
  end

end
