require "test_helper"

class PartnerAdmin::MembershipsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get partner_admin_memberships_show_url
    assert_response :success
  end

  test "should get new" do
    get partner_admin_memberships_new_url
    assert_response :success
  end

  test "should get create" do
    get partner_admin_memberships_create_url
    assert_response :success
  end

  test "should get update" do
    get partner_admin_memberships_update_url
    assert_response :success
  end

  test "should get delete" do
    get partner_admin_memberships_delete_url
    assert_response :success
  end
end
