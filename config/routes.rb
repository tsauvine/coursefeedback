Rails.application.routes.draw do

  #devise_for :users
  resource :session do
    get 'shibboleth'
  end

  resources :users

  resources :courses do
    resources :courseroles
  end

  resources :course_instances

  resources :topics do
    member do
      get 'vote'
      get 'moderate'
    end
  end

  resources :messages do
    member do
      get 'vote'
      get 'moderate'
    end
  end

  resources :faq_entries, :controller => 'faq' do
    member do
      get 'vote'
    end
  end

  #map.resources :surveys do , :path_prefix => ':course_code/:instance_path', :requirements => { :course_code => URL_FORMAT_ROUTE, :instance_path => URL_FORMAT_ROUTE }
  #  member do
  #    get 'answer'
  #    get 'results'
  #  end
  #end

  resources :survey_questions do
    member do
      get 'move'
    end
  end

  resources :survey_answers
  
  match '/login' => 'sessions#new', :as => :login
  match '/logout' => 'sessions#destroy', :as => :logout

  match '/:course/:instance/feedback', :to => 'topics#index', :constraints => { :course => URL_FORMAT_ROUTE, :instance => URL_FORMAT_ROUTE }, :as => 'topic_index'

  match '/:course/:instance/new_topic', :to => 'topics#new', :constraints => { :course => URL_FORMAT_ROUTE, :instance => URL_FORMAT_ROUTE }, :as => 'new_topic'

  match '/:course_code/:instance_path/faq', :to => 'faq#index', :constraints => { :course_code => URL_FORMAT_ROUTE, :instance_path => URL_FORMAT_ROUTE }, :as => 'faq'
  match '/:course_code/:instance_path/new_faq', :to => 'faq#new', :constraints => { :course_code => URL_FORMAT_ROUTE, :instance_path => URL_FORMAT_ROUTE }, :as => 'new_faq'

  match '/:course/:instance' => 'topics#index', :as => 'instance_root', :constraints => { :course => URL_FORMAT_ROUTE, :instance => URL_FORMAT_ROUTE }
  match '/:course_code', :to => 'courses#show', :constraints => { :course_code => URL_FORMAT_ROUTE }, :as => 'course_root'

  root :to => 'course_instances#index'

end
