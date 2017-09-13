# Copyright (c) 2017 Kristoffer Gronlund <kgronlund@suse.com>
# See COPYING for license.

Rails.application.routes.draw do
  scope module: 'api', as: 'api', defaults: {format: :json} do
    post '/login', to: "api#login"
    scope :status do
      get '/', to: "status#index", as: :status
      get '/cluster', to: "status#cluster"
      get '/cluster/state', to: "status#cluster_state"
      get '/cluster/connections', to: "status#cluster_connections"
      get '/cluster/events', to: "status#cluster_events"
      get '/tasks', to: "status#tasks"
      get '/nodes', to: "status#nodes"
      get '/resources', to: "status#resources"
      get '/nodes/:id', to: "status#node"
      get '/resources', to: "status#resources"
      get '/resources/:id', to: "status#resource"
      get '/tickets', to: "status#tickets"
      get '/tickets/:id', to: "status#ticket"
    end
  end
end
