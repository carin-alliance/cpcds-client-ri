################################################################################
#
# Home Controller
#
# Copyright (c) 2020 The MITRE Corporation.  All rights reserved.
#
################################################################################

class HomeController < ApplicationController

  before_action :establish_session_handler, only: [ :index ]

  #-----------------------------------------------------------------------------

  def index
    # Get list of patients from cached results from server
    load_patient_specific_data_from_server
    # binding.pry
    
  end

  
end
