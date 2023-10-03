Rails.application.routes.draw do

  resources :attendances, only: [] do
    member do
      patch :update_attendance_request
    end
  end

  get 'bases/index'

  root 'static_pages#top'
  get '/signup', to: 'users#new'

  # ログイン機能
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  get 'working_employees', to: 'users#working_employees', as: 'working_employees'

  resources :users do
    collection { post :import} #CSVファイルインポート
    
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
      get 'attendance_review'
    end
    
    resources :attendances, only: :update do
      member do
        patch :update_attendance_request
        get :approved_logs
      end
    end
  end

  resources :bases

  resources :overtime_requests, only: [:new, :create] do
    member do
      patch :update
      patch :approve_overtime
    end
  end

  resources :monthly_approvals, only: [:create, :update]
end