Rails.application.routes.draw do

  root :to => 'messages#index'

  resources :messages

  get 'lost_prescription', to: 'messages#lost_prescription', as: :lost_prescription

end
