require 'test_helper'

class CommentersControllerTest < ActionController::TestCase
  
  def setup
    @page = pages(:fb_profile)
  end
  
  test "should get index" do
    get :index, :page_id => @page.id
    assert_response :success
    assert_not_nil assigns(:commenters)
  end

  test "should get new" do
    get :new, :page_id => @page.id
    assert_response :success
  end

  test "should create commenters" do
    assert_difference 'Commenter.count', 3 do
      assert_difference "Invite.count", 3 do
        emails = ["avk@berkeley.edu", "hlhu@berkeley.edu", "mkocher@berkeley.edu"]
        post :create, :emails => emails.join(', '), :page_id => @page.id
      end
    end

    assert_redirected_to page_commenters_path(@page)
  end

  test "should show commenter" do
    get :show, :id => commenters(:one).id, :page_id => @page.id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => commenters(:one).id, :page_id => @page.id
    assert_response :success
  end

  test "should update commenter" do
    put :update, :id => commenters(:one).id, :commenter => valid_options_for_commenters, :page_id => @page.id
    assert_redirected_to page_commenter_path(@page, assigns(:commenter))
  end

  test "should destroy commenter" do
    assert_difference('Commenter.count', -1) do
      delete :destroy, :id => commenters(:one).id, :page_id => @page.id
    end

    assert_redirected_to page_commenters_path(@page)
  end

<<<<<<< HEAD:coreapp/test/functional/commenters_controller_test.rb
  test "should render page when new fails" do
    assert_no_difference('Commenter.count') do
      assert_no_difference "Invite.count" do
        emails = ['bullshit', '@.c', '9238740923874092837049823']
        post :create, :emails => emails.join(', '), :page_id => @page.id
      end
=======
  test "should render new when new commenter fails" do
  	assert_no_difference('Commenter.count') do
      post :create, :commenter => invalid_options_for_commenters, :page_id => @page.id
>>>>>>> commenters are now a nested resource of pages:coreapp/test/functional/commenters_controller_test.rb
    end
  
    assert_redirected_to @page
  end

  test "should render update when update commenter fails" do
	  put :update, :id => commenters(:one).id, :commenter => invalid_options_for_commenters, :page_id => @page.id
	  assert_template "edit"
  end
end
