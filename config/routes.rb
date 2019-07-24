Rails.application.routes.draw do
  root 'taxonomy_prints#new'
  # post "/taxonomy_prints" => 'taxonomy_prints#create'
  resources :taxonomy_prints, only: [:show]
end
