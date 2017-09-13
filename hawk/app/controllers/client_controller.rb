# Copyright (c) 2017 Kristoffer Gronlund <kgronlund@suse.com>
# Copyright (c) 2017 Ayoub Belarbi <abelarbi@suse.com>
# See COPYING for license.
require 'securerandom'


class ClientController < ApplicationController

  skip_before_action :verify_authenticity_token

  def index
    respond_to do |format|
      format.html do
        render
      end
      format.json do
        render json: {}, status: 200
      end
    end
  end
end
