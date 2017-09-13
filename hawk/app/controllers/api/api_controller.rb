# Copyright (c) 2017 Kristoffer Gronlund <kgronlund@suse.com>
# See COPYING for license.

module Api
  class ApiController < ActionController::API
    include ActionController::HttpAuthentication::Token::ControllerMethods

    before_action :authenticate, except: [ :login ]

    def login
      # authenticate username + password
      # generate token with expiry
      render json: { "login": "ok" }
    end

    protected

    # Authenticate the user with token based authentication
    def authenticate
      # authenticate user
      authenticate_token || render_unauthorized
    end

    def authenticate_token
      authenticate_with_http_token do |token, options|
        # decrypt token
        # extract current_user + expiry from token
        @current_user = "hacluster" if token == "1"
      end
    end

    def render_unauthorized(realm = "Application")
      self.headers["WWW-Authenticate"] = %(Token realm="#{realm.gsub(/"/, "")}")
      render json: 'Bad credentials', status: :unauthorized
    end
  end
end
