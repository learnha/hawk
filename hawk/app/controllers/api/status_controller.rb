# Copyright (c) 2017 Kristoffer Gronlund <kgronlund@suse.com>
# See COPYING for license.

module Api
  class StatusController < ApiController
    before_action :get_status

    def index
      render json: @status.root.to_json
    end

    def cluster
      render json: @status.cluster.to_json
    end

    def cluster_state
      render json: @status.state
    end

    def cluster_connections
      render json: @status.connections
    end

    def cluster_events
      render json: @status.events
    end

    def tasks
      render json: @status.tasks
    end

    def nodes
      render json: @status.nodes
    end

    def resources
      render json: @status.resources
    end

    def node
      render json: @status.node(params[:id])
    end

    def resource
      render json: @status.resource(params[:id])
    end

    def tickets
      render json: @status.tickets
    end

    def ticket
      render json: @status.ticket(params[:id])
    end

    private

    def get_status
      @status = Status.new @current_user
    end
  end
end
