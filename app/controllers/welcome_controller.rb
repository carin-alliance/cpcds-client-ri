################################################################################
#
# Welcome Controller
#
# Copyright (c) 2020 The MITRE Corporation.  All rights reserved.
#
################################################################################

class WelcomeController < ApplicationController

  def index
    setup_dalli
    puts "==>WelcomeController.index"
    #reset_session 
#    redirect_to launch_url
  end

end


