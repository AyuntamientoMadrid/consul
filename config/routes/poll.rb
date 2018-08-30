resources :polls, path: 'votaciones', only: [:show, :index] do
  member do
    get :stats, path: 'estadisticas'
    get :results, path: 'resultados'
  end

  resources :questions, path: 'preguntas', controller: 'polls/questions', shallow: true do
    post :answer, on: :member
  end
end
