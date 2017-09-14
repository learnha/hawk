# Copyright (c) 2017 Kristoffer Gronlund <kgronlund@suse.com>
# See COPYING for license.

require 'rexml/document' unless defined? REXML::Document
require 'rexml/xpath' unless defined? REXML::XPath

module Api
  class Status
    attr_accessor :state
    attr_accessor :events
    attr_accessor :connections
    attr_accessor :tasks

    def initialize(cib)
      @cib = cib
      @events = []
      @connections = []
      @tasks = []
      @state = "unknown"
      @state = "offline" if cib.mode == :offline
      @state = "online" if cib.mode == :online
    end

    def root
      {
        cluster: cluster,
        tasks: @tasks,
        nodes: nodes,
        resources: resources,
        tickets: tickets
      }
    end

    def cluster
      {
        state: @state,
        connections: @connections,
        events: @events
      }
    end

    def nodes
      @cib.nodes
    end

    def resources
      @cib.resources
    end

    # TODO:
    # Get list of tickets and ticket status
    # from booth
    def tickets
      return [] if @xml.nil?
      []
    end

    def error(message)
      @events << {
        message: message,
        type: "error",
        id: []
      }
    end
  end
end
