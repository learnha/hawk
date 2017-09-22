# Copyright (c) 2017 Kristoffer Gronlund <kgronlund@suse.com>
# See COPYING for license.

Rails.application.routes.draw do
  scope module: 'api', as: 'api', defaults: {format: :json} do
    post '/login', to: "api#login"
    get '/status', to: "status#index", as: :status
  end
end
