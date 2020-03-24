################################################################################
#
# Welcome Controller
#
# Copyright (c) 2019 The MITRE Corporation.  All rights reserved.
#
################################################################################

class WelcomeController < ApplicationController

  def index
    # binding.pry
    session[:iss_url] = nil
    session[:client_id] = nil
    session[:auth_url] = nil
    session[:access_token]=nil
#    redirect_to launch_url
  end

end


