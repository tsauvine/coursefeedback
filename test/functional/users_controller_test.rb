require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  

  

  protected
    def create_user(options = {})
      post :create, :user => { :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options)
    end
end
