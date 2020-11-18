################################################################################
#
# Claim Controller
#
# Copyright (c) 2020 The MITRE Corporation.  All rights reserved.
#
################################################################################

class ClaimController < ApplicationController
  def index
       #load_patient_specific_data_from_server
       pid = session[:patient_id]
       ## binding.pry if pid == nil 
       @fhir_claims = @fhir_claims || load_patient_resources(FHIR::Claim, nil, :patient, pid, :created )
       claims = fhir_claims.map { |eob| Claim.new(eob, @resources, @client) }.sort_by { |a|  -a.sortDate }
       @claims = claims
       @start_date = start_date
       @end_date = end_date    
  end

  def show
    @claims = fhir_explanationofbenefits.map { |eob| EOB.new(eob, @resources,@client) }
    reference = params[:id]
    @eob = @eobs.select{|p| p.id == reference}[0] 
  end

  def show 
    pid = session[:patient_id]
    id = params[:id]
    ## binding.pry if pid == nil 
    ## binding.pry 
    if @claims
      @claim = @claims.select{|p| p.id == id}[0] 
    elsif @fhir_claims
      fhir_claim = @fhir_claims.select{|p| p.id == id}[0]
      @claim = Claim.new(fhir_claim, @resources, @client)
    else
      fhir_claim = get_fhir_resources(@client, FHIR::Claim, id)[0]
      @claim = CLaim.new(fhir_claim, @resources, @client)
    end
  end
end

