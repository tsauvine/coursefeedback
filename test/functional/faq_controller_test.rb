require 'test_helper'

class FaqControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should get index without authentication" do
    get :index, :course_code => courses(:one).code, :instance_path => course_instances(:one).path
    assert_response :success
    assert_not_nil assigns(:entries)
  end
  

  test "new should redirect to login" do
    get :new, :course_code => courses(:one).code, :instance_path => course_instances(:one).path
    assert_redirected_to new_session_path
  end
  
  test "admin should get new" do
    login_as(:admin1)
    get :new, :course_code => courses(:one).code, :instance_path => course_instances(:one).path
    assert_response :success
    assert_not_nil assigns(:entry)
  end
  
  test "teacher of the course should get new" do
    login_as(:teacher1)
    
    get :new, :course_code => courses(:one).code, :instance_path => course_instances(:one).path
    assert_response :success
    assert_not_nil assigns(:entry)
  end
  
  test "teacher of another course should not get new" do
    login_as(:teacher2)
    get :new, :course_code => courses(:one).code, :instance_path => course_instances(:one).path
    assert_response :forbidden
  end
  
  test "student should not get new" do
    login_as(:student1)
    get :new, :course_code => courses(:one).code, :instance_path => course_instances(:one).path
    assert_response :forbidden
  end
  

  test "edit should redirect to login" do
    get :edit, :id => faq_entries(:one).id, :course_code => courses(:one).code, :instance_path => course_instances(:one).path
    assert_redirected_to new_session_path
  end

  test "admin should get edit" do
    login_as(:admin1)
    get :edit, :id => faq_entries(:one).id, :course_code => courses(:one).code, :instance_path => course_instances(:one).path
    assert_response :success
  end
  
  test "teacher of the course should get edit" do
    login_as(:teacher1)
    get :edit, :id => faq_entries(:one).id, :course_code => courses(:one).code, :instance_path => course_instances(:one).path
    assert_response :success
  end
  
  test "teacher of another course should not get edit" do
    login_as(:teacher2)
    get :edit, :id => faq_entries(:one).id, :course_code => courses(:one).code, :instance_path => course_instances(:one).path
    assert_response :forbidden
  end
  
  test "student should not get edit" do
    login_as(:student1)
    get :edit, :id => faq_entries(:one).id, :course_code => courses(:one).code, :instance_path => course_instances(:one).path
    assert_response :forbidden
  end
  

  test "create should redirect to login" do
    post :create, :faq_entry => {:course_id => courses(:one).id, :caption => 'Test', :question => 'q', :answer => 'a'}, :course_code => courses(:one).code, :instance_path => course_instances(:one).path
    assert_redirected_to new_session_path
  end
  
  test "admin should create faq entry" do
    login_as(:admin1)
    assert_difference('FaqEntry.count') do
      post :create, :faq_entry => {:course_id => courses(:one).id, :caption => 'Test', :question => 'q', :answer => 'a'}, :course_code => courses(:one).code, :instance_path => course_instances(:one).path
    end

    assert_redirected_to faq_path(assigns(:course).code, assigns(:instance).path)
  end
  
  test "teacher of the course should create faq entry" do
    login_as(:teacher1)
    assert_difference('FaqEntry.count') do
      post :create, :faq_entry => {:course_id => courses(:one).id, :caption => 'Test', :question => 'q', :answer => 'a'}, :course_code => courses(:one).code, :instance_path => course_instances(:one).path
    end

    assert_redirected_to faq_path(assigns(:course).code, assigns(:instance).path)
  end
  
  test "teacher of antoher course should not create faq entry" do
    login_as(:teacher2)
    assert_difference('FaqEntry.count', 0) do
      post :create, :faq_entry => {:course_id => courses(:one).id, :caption => 'Test', :question => 'q', :answer => 'a'}, :course_code => courses(:one).code, :instance_path => course_instances(:one).path
    end

    assert_response :forbidden
  end
  
  test "student should not create faq entry" do
    login_as(:student1)
    assert_difference('FaqEntry.count', 0) do
      post :create, :faq_entry => {:course_id => courses(:one).id, :caption => 'Test', :question => 'q', :answer => 'a'}, :course_code => courses(:one).code, :instance_path => course_instances(:one).path
    end

    assert_response :forbidden
  end

  
  test "update should redirect to login" do
    put :update, :faq_entry => {:course_id => courses(:one).id, :caption => 'Question', :question => 'w', :answer => 's'}, :id => faq_entries(:one).id, :course_code => courses(:one).code, :instance_path => course_instances(:one).path
    assert_redirected_to new_session_path
  end
  
  test "admin should update entry" do
    login_as(:admin1)
    put :update, :faq_entry => {:course_id => courses(:one).id, :caption => 'Question', :question => 'w', :answer => 's'}, :id => faq_entries(:one).id, :course_code => courses(:one).code, :instance_path => course_instances(:one).path
    assert_redirected_to faq_path(assigns(:course).code, assigns(:instance).path)
  end
  
  test "teacher of the course should update entry" do
    login_as(:teacher1)
    put :update, :faq_entry => {:course_id => courses(:one).id, :caption => 'Question', :question => 'w', :answer => 's'}, :id => faq_entries(:one).id, :course_code => courses(:one).code, :instance_path => course_instances(:one).path
    assert_redirected_to faq_path(assigns(:course).code, assigns(:instance).path)
  end
  
  test "teacher of another course should not update entry" do
    login_as(:teacher2)
    put :update, :faq_entry => {:course_id => courses(:one).id, :caption => 'Question', :question => 'w', :answer => 's'}, :id => faq_entries(:one).id, :course_code => courses(:one).code, :instance_path => course_instances(:one).path
    assert_response :forbidden
  end

  test "student should not update entry" do
    login_as(:student1)
    put :update, :faq_entry => {:course_id => courses(:one).id, :caption => 'Question', :question => 'w', :answer => 's'}, :id => faq_entries(:one).id, :course_code => courses(:one).code, :instance_path => course_instances(:one).path
    assert_response :forbidden
  end


  test "destroy should redirect to login" do
    assert_difference('FaqEntry.count', 0) do
      delete :destroy, :id => faq_entries(:one).id, :course_code => courses(:one).code, :instance_path => course_instances(:one).path
    end 
    
    assert_redirected_to new_session_path
  end
  
  test "admin should destroy entry" do
    login_as(:admin1)
    
    assert_difference('FaqEntry.count', -1) do
      delete :destroy, :id => faq_entries(:one).id, :course_code => courses(:one).code, :instance_path => course_instances(:one).path
    end

    assert_redirected_to faq_path(assigns(:course).code, assigns(:instance).path)
  end
  
  test "teacher of the course should destroy entry" do
    login_as(:teacher1)
    
    assert_difference('FaqEntry.count', -1) do
      delete :destroy, :id => faq_entries(:one).id, :course_code => courses(:one).code, :instance_path => course_instances(:one).path
    end

    assert_redirected_to faq_path(assigns(:course).code, assigns(:instance).path)
  end
  
  test "teacher of another course should not destroy entry" do
    login_as(:teacher2)
    
    assert_difference('FaqEntry.count', 0) do
      delete :destroy, :id => faq_entries(:one).id, :course_code => courses(:one).code, :instance_path => course_instances(:one).path
    end

    assert_response :forbidden
  end
  
  test "student should not destroy entry" do
    login_as(:student1)
    
    assert_difference('FaqEntry.count', 0) do
      delete :destroy, :id => faq_entries(:one).id, :course_code => courses(:one).code, :instance_path => course_instances(:one).path
    end

    assert_response :forbidden
  end
end
