require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end


  test "index as non-activated" do
    @non_admin.update_attribute(:activated, false)
    log_in_as(@admin)
    get users_path
    #assert_select 'a[href=?]', user_path(@non_admin), text: @non_adimn.name, count: 0
    assert_select 'a[href=?]', user_path(@non_admin), text: @non_admin.name, count: 0
    get user_path(@non_admin)
    assert_redirected_to root_url
  end

end
