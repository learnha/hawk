# Copyright (c) 2017 Kristoffer Gronlund <kgronlund@suse.com>
# See COPYING for license.

Rails.application.routes.draw do
  scope module: 'api', as: 'api' do
    get '/login', to: "api#login"
    scope :status do
      get '/', to: "status#index", as: :status
      get '/cluster', to: "cluster#index"
      resources :nodes, :resources, only: [:index, :show]
    end
  end
end
