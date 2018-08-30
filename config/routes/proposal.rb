resources :proposals, path: 'propuestas' do
  member do
    post :vote, path: 'apoyar'
    post :vote_featured
    put :flag
    put :unflag
    get :retire_form
    get :share, path: 'comparte'
    patch :retire
  end

  collection do
    get :map, path: 'mapa'
    get :suggest, path: 'sugiere'
    get :summary, path: 'resumen'
    put 'recommendations/disable', only: :index, controller: 'proposals', action: :disable_recommendations
  end
end
