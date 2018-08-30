namespace :moderation, path: 'moderacion' do
  root to: "dashboard#index"

  resources :users, path: 'usuarios', only: :index do
    member do
      put :hide
      put :hide_in_moderation_screen
    end
  end

  resources :debates, only: :index do
    put :hide, on: :member
    put :moderate, on: :collection
  end

  resources :proposals, path: 'propuestas', only: :index do
    put :hide, on: :member
    put :moderate, on: :collection
  end

  resources :comments, path: 'comentarios', only: :index do
    put :hide, on: :member
    put :moderate, on: :collection
  end

  resources :proposal_notifications, only: :index do
    put :hide, on: :member
    put :moderate, on: :collection
  end

  resources :budget_investments, only: :index, controller: 'budgets/investments' do
    put :hide, on: :member
    put :moderate, on: :collection
  end
end
