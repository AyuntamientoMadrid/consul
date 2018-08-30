resource :account, path: 'mi-cuenta', controller: "account", only: [:show, :update, :delete] do
  get :erase, on: :collection
end
