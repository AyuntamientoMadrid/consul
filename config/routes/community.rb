resources :communities, path: 'comunidades', only: [:show] do
  resources :topics, path: 'temas'
end
