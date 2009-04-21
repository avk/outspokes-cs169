require 'test_helper'

class CommentersControllerTest < ActionController::TestCase
  
  self.use_transactional_fixtures = false
  
  # def setup
  #   @page = pages(:fb_profile)
  # end
  # 
  # test "should get index" do
  #   get :index, :page_id => @page.id
  #   assert_response :success
  #   assert_not_nil assigns(:commenters)
  # end
  # 
  # test "should get new" do
  #   get :new, :page_id => @page.id
  #   assert_response :success
  # end
  # 
  # test "should create commenters" do
  #   emails = ["avk@berkeley.edu", "hlhu@berkeley.edu", "mkocher@berkeley.edu"]
  #   
  #   assert_difference 'Commenter.count', emails.size do
  #     assert_difference "Invite.count", emails.size do
  #       post :create, :emails => emails.join(', '), :page_id => @page.id
  #     end
  #   end
  # 
  #   assert_redirected_to page_commenters_path(@page)
  # end
  # 
  # test "should render page when new fails" do
  #   emails = ['bullshit', '@.c', '9238740923874092837049823']
  #   assert_no_difference('Commenter.count') do
  #     assert_no_difference "Invite.count" do
  #       post :create, :emails => emails.join(', '), :page_id => @page.id
  #     end
  #   end
  # 
  #   assert_redirected_to @page
  # end
  # 
  # test "should not invite duplicate commenters" do
  #   good_emails = ["avk@berkeley.edu", "hlhu@berkeley.edu", "mkocher@berkeley.edu"]
  #   mixed_emails = [good_emails.first, "json@berkeley.edu"]
  #   num_new = (good_emails | mixed_emails).size
  #   assert_difference "Commenter.count", num_new do
  #     assert_difference "Invite.count", num_new do
  #       post :create, :emails => good_emails.join(', '), :page_id => @page.id
  #       post :create, :emails => mixed_emails.join(', '), :page_id => @page.id
  #     end
  #   end
  # end
  # 
  # test "should be able to invite the same commenter to different pages" do
  #   commenter = "artvankilmer@berkeley.edu"
  #   assert_difference "Commenter.count", 1 do
  #     assert_difference "Invite.count", 2 do
  #       post :create, :emails => commenter, :page_id => pages(:rails_spikes).id
  #       post :create, :emails => commenter, :page_id => pages(:transactions).id
  #     end
  #   end
  # end
  # 
  # test "should show commenter" do
  #   get :show, :id => commenters(:one).id, :page_id => @page.id
  #   assert_response :success
  # end
  # 
  # test "should get edit" do
  #   get :edit, :id => commenters(:one).id, :page_id => @page.id
  #   assert_response :success
  # end
  # 
  # test "should update commenter" do
  #   put :update, :id => commenters(:one).id, :commenter => valid_options_for_commenters, :page_id => @page.id
  #   assert_redirected_to page_commenter_path(@page, assigns(:commenter))
  # end
  # 
  # test "should render update when update commenter fails" do
  #     put :update, :id => commenters(:one).id, :commenter => invalid_options_for_commenters, :page_id => @page.id
  #     assert_template "edit"
  # end
  # 
  # test "should destroy commenter" do
  #   assert_difference('Commenter.count', -1) do
  #     delete :destroy, :id => commenters(:one).id, :page_id => @page.id
  #   end
  # 
  #   assert_redirected_to page_commenters_path(@page)
  # end

end
