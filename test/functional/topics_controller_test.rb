require 'test_helper'

class TopicsControllerTest < ActionController::TestCase
 include Devise::TestHelpers

  # Require login
  [:show, :edit, :vote, :moderate].each do |action|
    define_method "test_#{action}_should_recuire_login" do  
      get action, :id => topics(:authenticated).id
      assert_redirected_to new_session_path
    end  
  end

  should "require login for show" do
    get :show, :id => topics(:authenticated).id
    assert_redirected_to new_session_path
  end

  should "require login for new" do
    get :new, :course => courses(:authenticated).code, :instance => course_instances(:authenticated).path
    assert_redirected_to new_session_path
  end
  
  should "require login for create" do
    post :create, :topic => {:course_instance_id => course_instances(:authenticated).id, :caption => 'Test', :text => 'Feedback'}
    assert_redirected_to new_session_path
  end

  
  # Topic index
  context "get topic index on public course without login" do
    setup do
      get :index, :course => courses(:public).code, :instance => course_instances(:public).path
    end
    
    should_respond_with :success
    should_render_template :index
    should "show headlines" do assert_select 'table.topics', true end
  end
  
  context "get topic index on a public without authorization to see headlines" do
    setup do
      get :index, :course => courses(:authenticated).code, :instance => course_instances(:authenticated).path
    end
    
    should_respond_with :success
    should_render_template :index
    should "not show headlines" do assert_select 'table.topics', false end
  end
  
  context "get topic index when logged in but not authorized to see headlines" do
    setup do
      login_as :student1
      get :index, :course => courses(:staff).code, :instance => course_instances(:staff).path
    end
    
    should_respond_with :success
    should_render_template :index
    should "not show headlines" do assert_select 'table.topics', false end
  end
  
  context "get topic index as a teacher" do
    setup do
      login_as :teacher1
      get :index, :course => courses(:one).code, :instance => course_instances(:one).path
    end
    
    should_respond_with :success
    should_render_template :index_staff
    should "show headlines" do assert_select 'table.topics', true end
  end
  
  
  # Student accessing forbidden topics
  [:staff, :moderated_pending, :moderated_censored, :moderated_deleted].each do |fixture|
    define_method "test_student_accessing_#{fixture}_topic" do  
      login_as :student1
      get :show, :id => topics(fixture).id
      assert_response :forbidden
    end  
  end
  
  # Teacher accessing topics
  [:staff, :moderated_pending, :moderated_censored, :moderated_deleted].each do |fixture|
    define_method "test_student_accessing_#{fixture}_topic" do  
      login_as :teacher1
      get :show, :id => topics(fixture).id
      assert_response :success
    end  
  end
    
  
  # New topic
  should "get new when not authenticated and authentication not required" do
    get :new, :course => courses(:public).code, :instance => course_instances(:public).path
    assert_response :success
  end
  
  context "create topic when not authenticated and authentication not required" do
    setup do
      post :create, :topic => {:course_instance_id => course_instances(:public).id, :caption => 'Test', :text => 'Feedback'}
    end
    
    should_redirect_to("index page") { topic_index_path(assigns(:course).code, assigns(:instance).path) }
  end
  
  context "create topic when authenticated and authentication required" do
    setup do
      login_as :student1
      post :create, :topic => {:course_instance_id => course_instances(:authenticated).id, :caption => 'Test', :text => 'Feedback'}
    end
    
    should_redirect_to("index page") { topic_index_path(assigns(:course).code, assigns(:instance).path) }
  end
  
  # Delete
  context "destroy topic as student" do
    setup do
      login_as :student1
      delete :destroy, :id => topics(:public).id
    end
    
    should_respond_with :forbidden
  end


end
