resources :budgets, path: 'presupuestos', only: [:show, :index] do
  resources :groups, path: 'grupo', controller: "budgets/groups", only: [:show]
  resources :investments, path: 'proyecto', controller: "budgets/investments", only: [:index, :new, :create, :show, :destroy] do
    member do
      post :vote
      put :flag
      put :unflag
    end

    collection { get :suggest }
  end

  resource :ballot, path: 'mis-votos', only: :show, controller: "budgets/ballots" do
    resources :lines, controller: "budgets/ballot/lines", only: [:create, :destroy]
  end

  resource :results, path: 'resultados', only: :show, controller: 'budgets/results'
  resource :executions, path: 'seguimiento', only: :show, controller: 'budgets/executions'
end

scope '/participatory_budget' do
  resources :spending_proposals, only: [:index, :new, :create, :show, :destroy], path: 'investment_projects' do
    post :vote, on: :member
  end
end

get 'investments/:id/json_data', action: :json_data, controller: 'budgets/investments'
