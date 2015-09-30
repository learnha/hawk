#======================================================================
#                        HA Web Konsole (Hawk)
# --------------------------------------------------------------------
#            A web-based GUI for managing and monitoring the
#          Pacemaker High-Availability cluster resource manager
#
# Copyright (c) 2009-2013 SUSE LLC, All Rights Reserved.
#
# Author: Tim Serong <tserong@suse.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of version 2 of the GNU General Public License as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it would be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
# Further, this software is distributed without any warranty that it is
# free of the rightful claim of any third person regarding infringement
# or the like.  Any license provided herein, whether implied or
# otherwise, applies only to this software file.  Patent licenses, if
# any, provided herein do not apply to combinations of this program with
# other software, or any other product whatsoever.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write the Free Software Foundation,
# Inc., 59 Temple Place - Suite 330, Boston MA 02111-1307, USA.
#
#======================================================================

require 'util'
require 'open3'

class MonitorController < ApplicationController
  include ActionController::Live

  skip_before_filter :set_users_locale
  skip_around_filter :inject_current_user_into_invoker
  before_filter :login_required

  def monitor
    ENV['QUERY_STRING'] = request.query_string.to_s
    ENV['HTTP_ORIGIN'] = request.env['HTTP_ORIGIN']

    response.headers['Content-Type'] = 'text/event-stream'
    Open3.popen3("/usr/sbin/hawk_monitor") do |i, o|
      result = o.read
      _, body = result.split("\n\n", 2)
      response.stream.write(body.to_s + "\n")
    end
  ensure
    response.stream.close
  end

end
