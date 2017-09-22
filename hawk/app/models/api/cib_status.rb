# Copyright (c) 2017 Kristoffer Gronlund <kgronlund@suse.com>
# See COPYING for license.

require 'cibtools'
require 'rexml/document' unless defined? REXML::Document
require 'rexml/xpath' unless defined? REXML::XPath

module Api
  class NodeState
    def initialize(root, name)
      @id = name
      @node = REXML::XPath.first(root, "/cib/configuration/nodes/node[@uname='#{name}']")
      @node = REXML::XPath.first(root, "/cib/configuration/nodes/node[@id='#{name}']") if @node.nil?
      @statenode = REXML::XPath.first(root, "/cib/status/node_state[@uname='#{name}']")
      @statenode = REXML::XPath.first(root, "/cib/status/node_state[@id='#{name}']") if @statenode.nil?
    end

    def id
      @id
    end

    # TODO
    def state
      :online
    end

    def type
      return :remote if @node.attributes["type"] == "remote" unless @node.nil?
      return :remote if @statenode.attributes["remote_node"] == "true" unless @statenode.nil?
      :local
    end

    def to_hash
      { id: id, state: state, type: type }
    end
  end

  class ResourceState
    def initialize(root, id)
      @id = id
      @config = REXML::XPath.first(root, "/cib/configuration//primitive[@id='#{id}']")
    end

    def id
      @id
    end

    def type
      return :clone if primitive.parent.name == "clone"
      return :multistate if primitive.parent.name == "master"
      :primitive
    end

    # TODO
    def state
      :running
    end

    def group
      return primitive.parent.attribute["id"] if primitive.parent.name == "group"
      ""
    end

    def to_hash
      { id: id, type: type, state: state, group: group }
    end
  end

  class CibStatus
    def initialize(user="hacluster")
      @mode = :none
      @xml = nil
      cmd = "/usr/sbin/cibadmin"
      unless File.exists?(cmd)
        Rails.logger.error "Pacemaker does not appear to be installed (#{cmd} not found)"
        return
      end
      unless File.executable?(cmd)
        Rails.logger.error "Unable to execute #{cmd}"
        return
      end
      out, err, status = Util.run_as(user, cmd, '-Ql')
      case status.exitstatus
      when 0
        @xml = REXML::Document.new(out)
        unless @xml && @xml.root
          Rails.logger.error "Failed to parse output of #{cmd} -Ql: #{out}"
          return
        end
      when 54, 13
        # 13 is cib_permission_denied (used to be 54, before pacemaker 1.1.8)
        Rails.logger.error "Permission denied for user #{user} calling #{cmd} -Ql"
        @mode = :offline
        return
      else
        Rails.logger.error "Error invoking #{cmd} -Ql: #{err}"
        @mode = :offline
        return
      end
      @mode = :online
    end

    def version
      if @mode == :online
        CibTools.epoch_string @xml.root
      else
        "0:0:0"
      end
    end

    def mode
      @mode
    end

    def xml
      @xml if @mode == :online
    end

    def nodes
      return [] if @xml.nil?
      @xml.elements.collect("/cib/configuration/nodes/node") do |xml|
        NodeState.new @xml, xml.attributes['uname'] || xml.attributes['id']
      end
    end

    def resources
      return [] if @xml.nil?
      @xml.elements.collect("/cib/configuration//primitive") do |xml|
        ResourceState.new @xml, xml.attributes['id']
      end
    end
  end
end
