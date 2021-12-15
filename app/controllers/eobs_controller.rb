################################################################################
#
# Eobs Controller
#
# Copyright (c) 2020 The MITRE Corporation.  All rights reserved.
#
################################################################################

class EobsController < ApplicationController
  before_action :connect_to_server, only: [ :index, :show ]

  # GET /eobs: show a collection of EOBs
  def index
    # Factor out initial search for all EOBs for a patient during the last year, or by service-date window if specified
    load_fhir_eobs(session[:patient_id])
    @start_date = start_date
    @end_date = end_date
  end

  # GET /eobs/[id]: show a single EOB
  def show
    eob_id = params[:id]
    # Factor out search for an EOB by id with patient id
    load_fhir_eobs(session[:patient_id], eob_id)
    if @eobs
      @eob = @eobs.select{|p| p.id == eob_id}[0]
    end
    redirect_back fallback_location: eobs_path, alert: 'Search not found: the EOB requested does not exist.' if @eob.nil?
  end

end
