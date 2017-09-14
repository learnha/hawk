# Copyright (c) 2017 Kristoffer Gronlund <kgronlund@suse.com>
# See COPYING for license.

module Api
  class ApiController < ActionController::API
    HAWK_CHKPWD = "/usr/sbin/hawk_chkpwd"
    include ActionController::HttpAuthentication::Token::ControllerMethods

    before_action :authenticate, except: [ :login ]

    def login
      # authenticate username + password
      # generate token with expiry
      unless authenticate_user(params[:username], params[:password])
        render_unauthorized
      else
        render json: { "token": token_for_user(params[:username]) }
      end
    end

    protected

    # Authenticate the user with token based authentication
    def authenticate
      # authenticate user
      authenticate_token || render_unauthorized
    end

    def token_for_user(username)
      # TODO
      "1"
    end

    def authenticate_token
      authenticate_with_http_token do |token, options|
        Rails.logger.debug "token: #{token} options: #{options}"
        @current_user = "hacluster" if token == token_for_user("hacluster")
      end
    end

    def render_unauthorized(realm = "Application")
      self.headers["WWW-Authenticate"] = %(Token realm="#{realm.gsub(/"/, "")}")
      render json: 'Bad credentials', status: :unauthorized
    end

    def authenticate_user(username, password)
      return false unless File.exists? HAWK_CHKPWD
      return false unless File.executable? HAWK_CHKPWD
      return false if username.blank?
      return false if password.blank?
      IO.popen("#{HAWK_CHKPWD} passwd #{username.shellescape}", "w+") do |pipe|
        pipe.write password
        pipe.close_write
      end
      $?.exitstatus == 0
    end

    def cib_status
      if @current_user
        @cib_status ||= begin CibStatus.new(@current_user) end
      end
    end
  end
end
