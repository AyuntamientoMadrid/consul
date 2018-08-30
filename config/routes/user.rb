resources :users, path: 'mi-actividad', only: [:show] do
  resources :direct_messages, path: 'mensajes-directos', only: [:new, :create, :show]
end
