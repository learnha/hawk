# Copyright (c) 2017 Kristoffer Gronlund <kgronlund@suse.com>
# See COPYING for license.

module Api
  class ResourcesController < ApiController

    # GET /status/resources
    def index
      render json: { "resources": "111" }
    end
  end
end
