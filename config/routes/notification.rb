resources :notifications, path: 'notificaciones', only: [:index, :show] do
  put :mark_as_read, on: :member, path: 'marcar-como-leida'
  put :mark_all_as_read, on: :collection, path: 'marcar-todas-como-leidas'
  put :mark_as_unread, on: :member, path: 'marcar-como-no-leida'
  get :read, on: :collection, path: 'leer'
end

resources :proposal_notifications, path: 'notificaciones-de-propuestas', only: [:new, :create, :show]
