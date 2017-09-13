# Copyright (c) 2017 Kristoffer Gronlund <kgronlund@suse.com>
# See COPYING for license.

module Api
  class NodesController < ApiController

    # GET /api/v0/status/nodes
    def index
      render json: { "nodes": "111" }
    end
  end
end
