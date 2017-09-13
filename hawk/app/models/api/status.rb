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

    def initialize(user)
      @xml = nil
      @state = "unknown"
      @events = []
      @connections = []
      @tasks = []
      unless File.exists?('/usr/sbin/cibadmin')
        error _('Pacemaker does not appear to be installed (%{cmd} not found)') % {
          cmd: '/usr/sbin/cibadmin' }
        init_uninstalled_cluster
        return
      end
      unless File.executable?('/usr/sbin/cibadmin')
        error _('Unable to execute %{cmd}') % {cmd: '/usr/sbin/cibadmin' }
        init_uninstalled_cluster
        return
      end
      out, err, status = Util.run_as(user, 'cibadmin', '-Ql')
      case status.exitstatus
      when 0
        @xml = REXML::Document.new(out)
        unless @xml && @xml.root
          error _('Error invoking %{cmd}') % {cmd: 'cibadmin -Ql' }
          init_offline_cluster
          return
        end
      when 54, 13
        # 13 is cib_permission_denied (used to be 54, before pacemaker 1.1.8)
        error _('Permission denied for user %{user}') % {user: user}
        init_offline_cluster
        return
      else
        error _('Error invoking %{cmd}: %{msg}') % {cmd: 'cibadmin -Ql', msg: err }
        init_offline_cluster
        return
      end

      @state = "online"
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
      return [] if @xml.nil?
      @xml.elements.collect("/cib/configuration/nodes/node") do |xml|
        {
          id: xml.attributes['uname'] || xml.attributes['id'],
          type: xml.attributes['type'] || 'local',
          state: "online"
        }
      end
    end

    def resources
      return [] if @xml.nil?
      @xml.elements.collect("/cib/configuration//primitive") do |xml|
        {
          id: xml.attributes['uname'] || xml.attributes['id'],
          type: xml.name,
          state: "running",
          location: [],
        }
      end
    end

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

    def init_offline_cluster
      @state = "offline"
      @xml = nil
    end

    def init_uninstalled_cluster
      @state = "none"
      @xml = nil
    end
  end
end
