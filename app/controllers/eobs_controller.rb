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
    # patient_id = session[:patient_id]

    # Factor out initial search for all EOBs for a patient during the last year, or by service-date window if specified 

    eobid = nil 
    @client = FHIR::Client.new(session[:iss_url])
    @client.use_r4
    @client.set_bearer_token(session[:access_token])
    eobid = nil 
    load_fhir_eobs(session[:patient_id], eobid)
    @start_date = start_date
    @end_date = end_date 
  end

  # GET /eobs/[id]: show a single EOB
  def show
    #patient_id = session[:patient_id]
    eob_id = params[:id]
    # Factor out search for an EOB by id with patient id 
    load_fhir_eobs(session[:patient_id], eob_id) 
    @eob = nil
    if @eobs
      @eob = @eobs.select{|p| p.id == eob_id}[0] 
    end
  rescue StandardError => exception
    reset_session
    err = "Failed to connect: " + exception.message
    redirect_to root_path, alert: err
  end

end
