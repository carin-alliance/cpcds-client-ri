################################################################################
#
# Welcome Controller
#
# Copyright (c) 2019 The MITRE Corporation.  All rights reserved.
#
################################################################################

class WelcomeController < ApplicationController

  def index
    binding.pry
    session[:iss_url] = params[:iss_url]
    session[:client_id] = params[:client_id]
    session[:auth_url] = nil
    session[:access_token]=nil
#    redirect_to launch_url
  end

end


