# frozen_string_literal: true

Rails.application.routes.draw do
  api_guard_routes for: 'users'

  defaults format: :json do
    resources :events, only: %i[index show]
    resources :reservations, only: %i[index show create] do
      member do
        post 'pay'
      end
    end
  end
end
