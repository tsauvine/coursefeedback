require 'test_helper'

class TopicsControllerTest < ActionController::TestCase
#   context "on GET to :show for first record" do
#     setup do
#       course = Course.new
#       instance = Instance.new(:course => course)
#       topic = Topic.new(:instance => instance)
#       
#       
#       get :show, :id => 1
#     end
# 
#     
#     should_redirect_to new_session_path
#     
#     should_assign_to :user
#     should_respond_with :success
#     should_render_template :show
#     should_not_set_the_flash
# 
#     should "do something else really cool" do
#       assert_equal 1, assigns(:user).id
#     end
#   end


  should "require login for show" do
    get :show, :id => topics(:one).to_param
    assert_redirected_to new_session_path
  end

#   test "should get index" do
#     get :index
#     assert_response :success
#     assert_not_nil assigns(:topics)
#   end
# 
#   test "should get new" do
#     get :new
#     assert_response :success
#   end
# 
#   test "should create topic" do
#     assert_difference('Topic.count') do
#       post :create, :topic => { }
#     end
# 
#     assert_redirected_to topic_path(assigns(:topic))
#   end
# 
#   test "should show topic" do
#     get :show, :id => topics(:one).to_param
#     assert_response :success
#   end
# 
#   test "should get edit" do
#     get :edit, :id => topics(:one).to_param
#     assert_response :success
#   end
# 
#   test "should update topic" do
#     put :update, :id => topics(:one).to_param, :topic => { }
#     assert_redirected_to topic_path(assigns(:topic))
#   end
# 
#   test "should destroy topic" do
#     assert_difference('Topic.count', -1) do
#       delete :destroy, :id => topics(:one).to_param
#     end
# 
#     assert_redirected_to topics_path
#   end
end
