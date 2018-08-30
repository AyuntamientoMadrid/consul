resources :tags, path: 'etiquetas' do
  collection do
    get :suggest, path: 'sugiere'
  end
end
