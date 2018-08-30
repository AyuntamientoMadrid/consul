namespace :admin do
  root to: "dashboard#index"
  resources :organizations, path: 'organizaciones', only: :index do
    get :search, on: :collection
    member do
      put :verify
      put :reject
    end
  end

  resources :hidden_users, path: 'usuarios-bloqueados', only: [:index, :show] do
    member do
      put :restore
      put :confirm_hide
    end
  end

  resources :hidden_budget_investments, path: 'proyectos-bloqueados', only: :index do
    member do
      put :restore
      put :confirm_hide
    end
  end

  resources :debates, path: 'debates', only: :index do
    member do
      put :restore
      put :confirm_hide
    end
  end

  resources :proposals, path: 'propuestas', only: :index do
    member do
      put :restore
      put :confirm_hide
    end
  end

  resources :proposal_notifications, only: :index do
    member do
      put :restore
      put :confirm_hide
    end
  end

  ### Modified in: config/routes/custom.rb
  ### ToDo: Figure out a way to maintain Consul's routes in this file,
  #         whilst modifying them in routes/custom.rb
  #         The main problem is that routes can not be duplicated
  ###

  #resources :spending_proposals, only: [:index, :show, :edit, :update] do
  #  member do
  #    patch :assign_admin
  #    patch :assign_valuators
  #  end
  #
  #  get :summary, on: :collection
  #end

  resources :budgets, path: 'presupuestos' do
    member do
      put :calculate_winners
    end

    resources :budget_groups, path: 'grupos' do
      resources :budget_headings
    end

    resources :budget_investments, path: 'proyectos', only: [:index, :show, :edit, :update] do
      resources :budget_investment_milestones, path: 'hitos'
      member { patch :toggle_selection }
    end

    resources :budget_phases, path: 'fases-del-presupuesto', only: [:edit, :update]
  end

  resources :budget_investment_statuses, path: 'estados-de-proyecto', only: [:index, :new, :create, :update, :edit, :destroy]

  resources :signature_sheets, path: 'hojas-de-firmas', only: [:index, :new, :create, :show]

  resources :banners, only: [:index, :new, :create, :edit, :update, :destroy] do
    collection { get :search }
  end

  resources :comments, path: 'comentarios', only: :index do
    member do
      put :restore
      put :confirm_hide
    end
  end

  resources :tags, path: 'temas', only: [:index, :create, :update, :destroy]

  resources :officials, path: 'cargos-publicos', only: [:index, :edit, :update, :destroy] do
    get :search, on: :collection
  end

  resources :settings, path: 'configuracion', only: [:index, :update]
  put :update_map, to: "settings#update_map"

  resources :moderators, path: 'moderadores', only: [:index, :create, :destroy] do
    get :search, on: :collection
  end

  resources :valuators, path: 'evaluadores', only: [:show, :index, :edit, :update, :create, :destroy] do
    get :search, on: :collection
    get :summary, on: :collection
  end

  resources :valuator_groups, path: 'grupos-de-evaluadores'

  resources :managers, path: 'gestores', only: [:index, :create, :destroy] do
    get :search, on: :collection
  end

  resources :administrators, path: 'administradores', only: [:index, :create, :destroy] do
    get :search, on: :collection
  end

  resources :users, path: 'usuarios', only: [:index, :show]

  scope module: :poll do
    resources :polls, path: 'votaciones' do
      get :booth_assignments, on: :collection, path: 'asignacion-de-urnas'
      patch :add_question, on: :member

      resources :booth_assignments, path: 'asignacion-de-urnas', only: [:index, :show, :create, :destroy] do
        get :search_booths, on: :collection, path: 'buscar-urnas'
        get :manage, on: :collection, path: 'gestionar'
      end

      resources :officer_assignments, only: [:index, :create, :destroy] do
        get :search_officers, on: :collection
        get :by_officer, on: :collection
      end

      resources :recounts, only: :index
      resources :results, only: :index
    end

    resources :officers, path: 'presidentes-de-mesa' do
      get :search, on: :collection
    end

    resources :booths, path: 'urnas' do
      get :available, on: :collection, path: 'asignar-turnos'

      resources :shifts, path: 'turnos' do
        get :search_officers, on: :collection
      end
    end

    resources :questions, path: 'preguntas-ciudadanas', shallow: true do
      resources :answers, except: [:index, :destroy], controller: 'questions/answers' do
        resources :images, controller: 'questions/answers/images'
        resources :videos, controller: 'questions/answers/videos'
        get :documents, to: 'questions/answers#documents'
      end
      post '/answers/order_answers', to: 'questions/answers#order_answers'
    end
  end

  resources :verifications, controller: :verifications, only: :index do
    get :search, on: :collection
  end

  resource :activity, path: 'actividad', controller: :activity, only: :show

  resources :newsletters do
    member do
      post :deliver
    end
    get :users, on: :collection
  end

  resources :admin_notifications, path: 'notificaciones' do
    member do
      post :deliver
    end
  end

  resources :system_emails, only: [:index] do
    get :view
    get :preview_pending
    put :moderate_pending
    put :send_pending
  end

  resources :emails_download, path: 'descarga-de-emails', only: :index do
    get :generate_csv, on: :collection
  end

  resource :stats, path: 'estadisticas', only: :show do
    get :proposal_notifications, on: :collection, path: 'notificaciones-de-propuestas'
    get :direct_messages, on: :collection, path: 'mensajes-directos'
    get :polls, on: :collection, path: 'propuestas'
  end

  namespace :legislation, path: 'legislacion' do
    resources :processes, path: 'procesos' do
      resources :questions, path: 'preguntas-ciudadanas'
      resources :proposals, path: 'propuestas'
      resources :draft_versions, path: 'borradores'
    end
  end

  namespace :api do
    resource :stats, only: :show
  end

  resources :geozones, path: 'distritos', only: [:index, :new, :create, :edit, :update, :destroy]

  namespace :site_customization, path: 'personalizacion' do
    resources :pages, except: [:show], path: 'paginas'
    resources :images, only: [:index, :update, :destroy], path: 'imagenes'
    resources :content_blocks, except: [:show], path: 'bloques'
    resources :information_texts, only: [:index], path: 'textos-de-informacion' do
      post :update, on: :collection
    end
  end

  resource :homepage, controller: :homepage, only: [:show]

  namespace :widget do
    resources :cards
    resources :feeds, only: [:update]
  end
end
