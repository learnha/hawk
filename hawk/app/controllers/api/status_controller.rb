# Copyright (c) 2017 Kristoffer Gronlund <kgronlund@suse.com>
# See COPYING for license.

module Api
  class StatusController < ApiController
    before_action :get_status

    def index
      render json: @status.root.to_json
    end

    private

    def get_status
      @status = Status.new(cib_status)
    end
  end
end
