namespace :valuation, path: 'evaluacion' do
  root to: "budgets#index"

  resources :spending_proposals, only: [:index, :show, :edit] do
    patch :valuate, on: :member
  end

  resources :budgets, path: 'presupuestos', only: :index do
    resources :budget_investments, path: 'proyectos', only: [:index, :show, :edit] do
      patch :valuate, on: :member
    end
  end
end
