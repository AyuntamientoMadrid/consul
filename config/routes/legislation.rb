namespace :legislation, path: 'legislacion' do
  resources :processes, path: 'procesos', only: [:index, :show] do
    member do
      get :debate, path: 'debate'
      get :draft_publication, path: 'borrador'
      get :allegations, path: 'alegaciones'
      get :result_publication, path: 'resultados'
      get :proposals, path: 'propuestas'
    end

    resources :questions, path: 'preguntas', only: [:show] do
      resources :answers, only: [:create]
    end

    resources :proposals, path: 'propuestas' do
      member do
        post :vote
        put :flag
        put :unflag
      end
      collection do
        get :map, path: 'mapa'
        get :suggest, path: 'sugiere'
      end
    end

    resources :draft_versions, path: 'borradores', only: [:show] do
      get :go_to_version, on: :collection
      get :changes
      resources :annotations do
        get :search, on: :collection
        get :comments
        post :new_comment
      end
      resources :annotations, path: 'anotaciones'
    end
  end
end
