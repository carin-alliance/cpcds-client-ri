################################################################################
#
# Dashboard Controller
#
# Copyright (c) 2019 The MITRE Corporation.  All rights reserved.
#
################################################################################

class DashboardController < ApplicationController
  before_action :establish_session_handler, only: [ :index, :show ]
  def index
  #   load_patient_specific_data_from_server
    # sets up @patient
    @patient = Patient.new(@fhir_patients[0], @resources, @client)
  end

end
