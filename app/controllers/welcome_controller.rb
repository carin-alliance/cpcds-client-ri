################################################################################
#
# Welcome Controller
#
# Copyright (c) 2020 The MITRE Corporation.  All rights reserved.
#
################################################################################

class WelcomeController < ApplicationController

  def index
    puts "==>WelcomeController.index"
    @client = session[:client]
    #reset_session
#    redirect_to launch_url
  end

end


