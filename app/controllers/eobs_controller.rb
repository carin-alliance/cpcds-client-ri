################################################################################
#
# Eobs Controller
#
# Copyright (c) 2020 The MITRE Corporation.  All rights reserved.
#
################################################################################

class EobsController < ApplicationController
  before_action :connect_to_server, only: [ :index, :show ]

  # GET /eobs 
  def index # show a collection of EOBs
    patient_id = session[:patient_id]

    # Factor out initial search for all EOBs for a patient during the last year, or by service-date window if specified 
    load_fhir_eobs (patient_id)
    @start_date = start_date
    @end_date = end_date 
    binding.pry 
  end

  # GET /eobs/[id] 
  def show # show a single EOB
    patient_id = session[:patient_id]
    id = params[:id]

    # Factor out search for an EOB by id with patient id 
    load_fhir_eobs (patient_id, eob_id=id) 
    @eob = nil
    if @eobs
      @eob = @eobs.select{|p| p.id == id}[0] 
    end
    binding.pry 
  end

end
