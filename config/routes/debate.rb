resources :debates do
  member do
    post :vote
    put :flag
    put :unflag
    put :mark_featured
    put :unmark_featured
  end

  collection do
    get :map, path: 'mapa'
    get :suggest, path: 'sugiere'
    put 'recommendations/disable', only: :index, controller: 'debates', action: :disable_recommendations
  end
end
