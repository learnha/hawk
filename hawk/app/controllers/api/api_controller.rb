# Copyright (c) 2017 Kristoffer Gronlund <kgronlund@suse.com>
# See COPYING for license.

module Api
  class ApiController < ActionController::API
    def login
      render json: { "resources": "111" }
    end
  end
end
