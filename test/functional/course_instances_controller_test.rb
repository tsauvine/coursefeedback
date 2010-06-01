require 'test_helper'

class CourseInstancesControllerTest < ActionController::TestCase
  test "should get index without authentication" do
    get :index
    assert_response :success
    assert_not_nil assigns(:course_instances)
  end
  
  test "should show without authentication" do
    get :show, :id => course_instances(:one).to_param
    assert_response :success
    assert_not_nil assigns(:instance)
  end
  
  
  test "new should redirect to login" do
    get :new, :course_id => courses(:one).to_param
    assert_redirected_to new_session_path
  end
  
  test "teacher of the course should get new" do
    login_as(:teacher1)
    get :new, :course_id => courses(:one).to_param
    assert_response :success
  end
  
  test "teacher of another course should not get new" do
    login_as(:teacher2)
    get :new, :course_id => courses(:one).to_param
    assert_response :forbidden
  end
  
  test "student should not get new" do
    login_as(:student1)
    get :new, :course_id => courses(:one).to_param
    assert_response :forbidden
  end  

  test "admin should get new" do
    login_as(:admin1)
    get :new, :course_id => courses(:one).to_param
    assert_response :success
  end


  test "edit should redirect to login" do
    get :edit, :id => course_instances(:one).to_param
    assert_redirected_to new_session_path
  end

  test "student should not get edit" do
    login_as(:student1)
    get :edit, :id => course_instances(:one).to_param
    assert_response :forbidden
  end
  
  test "teacher of the course should get edit" do
    login_as(:teacher1)
    get :edit, :id => course_instances(:one).to_param
    assert_response :success
  end
  
  test "teacher of another course should not get edit" do
    login_as(:teacher2)
    get :edit, :id => course_instances(:one).to_param
    assert_response :forbidden
  end

  test "admin should get edit" do
    login_as(:admin1)
    get :edit, :id => course_instances(:one).to_param
    assert_response :success
  end


  test "create should redirect to login" do
    post :create, :course_instance => {:course_id => courses(:one).id, :path => 'spring', :name => 'Spring'}
    assert_redirected_to new_session_path
  end
  
  test "admin should create instance" do
    login_as(:admin1)
    assert_difference('CourseInstance.count') do
      post :create, :course_instance => {:course_id => courses(:one).id, :path => 'spring', :name => 'Spring'}
    end

    assert_redirected_to edit_course_path(assigns(:course))
  end
  
  test "teacher of the course should create instance" do
    login_as(:teacher1)
    assert_difference('CourseInstance.count', 1) do
      post :create, :course_instance => {:course_id => courses(:one).id, :path => 'spring', :name => 'Spring'}
    end

    assert_redirected_to edit_course_path(assigns(:course))
  end
  
  test "teacher of another course should not create instance" do
    login_as(:teacher2)
    assert_difference('CourseInstance.count', 0) do
      post :create, :course_instance => {:course_id => courses(:one).id, :path => 'spring', :name => 'Spring'}
    end

    assert_response :forbidden
  end
  
  test "student should not create instance" do
    login_as(:student1)
    assert_difference('CourseInstance.count', 0) do
      post :create, :course_instance => {:course_id => courses(:one).id, :path => 'spring', :name => 'Spring'}
    end

    assert_response :forbidden
  end
  
  
  test "update should redirect to login" do
    put :update, :id => course_instances(:one).to_param, :course_instance => {:path => 'fall', :name => 'Fall'}
    assert_redirected_to new_session_path
  end
  
  test "admin should update instance" do
    login_as(:admin1)
    put :update, :id => course_instances(:one).to_param, :course_instance => {:path => 'fall', :name => 'Fall'}
    assert_redirected_to edit_course_path(assigns(:course))
  end
  
  test "teacher of the course should update instance" do
    login_as(:teacher1)
    put :update, :id => course_instances(:one).to_param, :course_instance => {:path => 'fall', :name => 'Fall'}
    assert_redirected_to edit_course_path(assigns(:course))
  end
  
  test "teacher of another course should not update instance" do
    login_as(:teacher2)
    put :update, :id => course_instances(:one).to_param, :course_instance => {:path => 'fall', :name => 'Fall'}
    assert_response :forbidden
  end

  test "student should not update instance" do
    login_as(:student1)
    put :update, :id => course_instances(:one).to_param, :course_instance => {:path => 'fall', :name => 'Fall'}
    assert_response :forbidden
  end


  test "destroy should redirect to login" do
    assert_difference('CourseInstance.count', 0) do
      delete :destroy, :id => course_instances(:one).to_param
    end 
    
    assert_redirected_to new_session_path
  end
  
  test "admin should destroy instance" do
    login_as(:admin1)
    
    assert_difference('CourseInstance.count', -1) do
      delete :destroy, :id => course_instances(:one).to_param
    end

    assert_redirected_to edit_course_path(assigns(:course))
  end
  
  test "teacher should destroy instance" do
    login_as(:teacher1)
    
    assert_difference('CourseInstance.count', -1) do
      delete :destroy, :id => course_instances(:one).to_param
    end

    assert_redirected_to edit_course_path(assigns(:course))
  end
  
  test "teacher of another course should not destroy instance" do
    login_as(:teacher2)
    
    assert_difference('CourseInstance.count', 0) do
      delete :destroy, :id => course_instances(:one).to_param
    end

    assert_response :forbidden
  end
  
  test "student should not destroy instance" do
    login_as(:student1)
    
    assert_difference('CourseInstance.count', 0) do
      delete :destroy, :id => course_instances(:one).to_param
    end

    assert_response :forbidden
  end
end
