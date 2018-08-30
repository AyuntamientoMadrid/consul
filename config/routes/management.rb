namespace :management, path: 'gestion' do
  root to: "dashboard#index"

  resources :document_verifications, path: 'verificacion-documento', only: [:index, :new, :create] do
    post :check, on: :collection
  end

  resources :email_verifications, path: 'verificacion-email', only: [:new, :create]
  resources :user_invites, path: 'invitaciones', only: [:new, :create]

  resources :users, path: 'usuarios', only: [:new, :create] do
    collection do
      delete :logout, path: 'cambiar'
      delete :erase
    end
  end

  resource :account, path: 'cuenta', controller: "account", only: [:show] do
    get :print_password, path: 'imprimir-contrasena'
    patch :change_password
    get :reset_password, path: 'restablecer-contrasena'
    get :edit_password_email, path: 'contrasena-via-email'
    get :edit_password_manually, path: 'contrasena-manualmente'
  end

  resource :session, path: 'sesion', only: [:create, :destroy]
  get 'sign_in', to: 'sessions#create', as: :sign_in, path: 'entrar'

  resources :proposals, path: 'propuestas', only: [:index, :new, :create, :show] do
    post :vote, on: :member
    get :print, on: :collection, path: 'imprimir'
  end

  resources :spending_proposals, only: [:index, :new, :create, :show] do
    post :vote, on: :member
    get :print, on: :collection
  end

  resources :budgets, path: 'presupuestos', only: :index do
    collection do
      get :create_investments, path: 'crear-proyecto'
      get :support_investments, path: 'apoyar-proyecto'
      get :print_investments, path: 'imprimir-proyecto'
    end

    resources :investments, path: 'proyectos', only: [:index, :new, :create, :show, :destroy], controller: 'budgets/investments' do
      post :vote, on: :member
      get :print, on: :collection, path: 'imprimir'
    end
  end
end
