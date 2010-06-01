require 'test_helper'

class CoursesControllerTest < ActionController::TestCase
  test "should get index without authentication" do
    get :index
    assert_response :success
    assert_not_nil assigns(:courses)
  end
  
  test "should show without authentication" do
    get :show, :id => courses(:one).to_param
    assert_response :success
    assert_not_nil assigns(:course)
  end
  
  
  test "new should redirect to login" do
    get :new
    assert_redirected_to new_session_path
  end
  
  test "student should not get new" do
    login_as(:student1)
    get :new
    assert_response :forbidden
  end
  
  test "teacher should not get new" do
    login_as(:teacher1)
    get :new
    assert_response :forbidden
  end
  
  test "admin should get new" do
    login_as(:admin1)
    get :new
    assert_response :success
  end


  test "edit should redirect to login" do
    get :edit, :id => courses(:one).to_param
    assert_redirected_to new_session_path
  end

  test "student should not get edit" do
    login_as(:student1)
    get :edit, :id => courses(:one).to_param
    assert_response :forbidden
  end
  
  test "teacher of the course should get edit" do
    login_as(:teacher1)
    get :edit, :id => courses(:one).to_param
    assert_response :success
  end
  
  test "teacher of another course should not get edit" do
    login_as(:teacher2)
    get :edit, :id => courses(:one).to_param
    assert_response :forbidden
  end

  test "admin should get edit" do
    login_as(:admin1)
    get :edit, :id => courses(:one).to_param
    assert_response :success
  end
  

  test "create should redirect to login" do
    post :create, :course => {:code => '12345', :name => 'Test'}
    assert_redirected_to new_session_path
  end
  
  test "admin should create course" do
    login_as(:admin1)
    assert_difference('Course.count') do
      post :create, :course => {:code => '12345', :name => 'Test'}
    end

    assert_redirected_to edit_course_path(assigns(:local_course))
  end
  
  test "student should not create course" do
    login_as(:student1)
    assert_difference('Course.count', 0) do
      post :create, :course => {:code => '12345', :name => 'Test'}
    end

    assert_response :forbidden
  end
  
  test "teacher should not create course" do
    login_as(:teacher1)
    assert_difference('Course.count', 0) do
      post :create, :course => {:code => '12345', :name => 'Test'}
    end

    assert_response :forbidden
  end

  
  test "update should redirect to login" do
    put :update, :id => courses(:one).to_param, :course => {:code => '99999', :name => 'New name'}
    assert_redirected_to new_session_path
  end
  
  test "teacher of the course should update course" do
    login_as(:teacher1)
    put :update, :id => courses(:one).to_param, :course => {:code => '99999', :name => 'New name'}
    assert_redirected_to edit_course_path(assigns(:local_course))
  end
  
  test "teacher of another course should not update course" do
    login_as(:teacher2)
    put :update, :id => courses(:one).to_param, :course => {:code => '99999', :name => 'New name'}
    assert_response :forbidden
  end

  test "student should not update course" do
    login_as(:student1)
    put :update, :id => courses(:one).to_param, :course => {:code => '99999', :name => 'New name'}
    assert_response :forbidden
  end


  test "destroy should redirect to login" do
    assert_difference('Course.count', 0) do
      delete :destroy, :id => courses(:one).to_param
    end 
    
    assert_redirected_to new_session_path
  end
  
  test "admin should destroy course" do
    login_as(:admin1)
    
    assert_difference('Course.count', -1) do
      delete :destroy, :id => courses(:one).to_param
    end

    assert_redirected_to courses_path
  end
  
  test "teacher should not destroy course" do
    login_as(:teacher1)
    
    assert_difference('Course.count', 0) do
      delete :destroy, :id => courses(:one).to_param
    end

    assert_response :forbidden
  end
  
  test "student should not destroy course" do
    login_as(:student1)
    
    assert_difference('Course.count', 0) do
      delete :destroy, :id => courses(:one).to_param
    end

    assert_response :forbidden
  end
end
