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
  def index # read a bundle from a file 
    patient_id = session[:patient_id]
    binding.pry if patient_id == nil 
    @fhir_explanationofbenefits = @fhir_explanationofbenefits || load_patient_resources(FHIR::ExplanationOfBenefit, nil, :patient, patient_id, :created )
    explanationofbenefits = fhir_explanationofbenefits.map { |eob| EOB.new(eob, @resources, @client, patient_id) }.sort_by { |a|  -a.sortDate }
    @eobs = explanationofbenefits
    @start_date = start_date
    @end_date = end_date 
  end

  # GET /eobs/[id] 
  def show 
    patient_id = session[:patient_id]
    id = params[:id]
    binding.pry if patient_id == nil 

    search = { parameters: { _id: patient_id } }
    results = @client.search(FHIR::Patient, search: search )
    @patient = Patient.new(results.resource.entry.map(&:resource)[0], @client)

    # binding.pry 
    if @eobs
      @eob = @eobs.select{|p| p.id == id}[0] 
    elsif @fhir_explanationofbenefits
      fhir_explanationofbenefit = @fhir_explanationofbenefits.select{|p| p.id == id}[0]
      @eob = EOB.new(fhir_explanationofbenefit, @resources, @client, patient_id)
    else
      fhir_explanationofbenefit = get_fhir_resources(@client, FHIR::ExplanationOfBenefit, id, patient_id)[0]
      @eob = EOB.new(fhir_explanationofbenefit, @resources, @client, patient_id)
    end
    # binding.pry 
  end

end
