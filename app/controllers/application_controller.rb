################################################################################
#
# Application Controller
#
# Copyright (c) 2020 The MITRE Corporation.  All rights reserved.
#
################################################################################

class ApplicationController < ActionController::Base
  require 'rest-client'
  require 'json'

  attr_accessor :explanationofbenefits, :practitioners, :patients, :locations, :organizations, :practitionerroles, :coverages, :resources
  attr_accessor :fhir_explanationofbenefits,  :fhir_practitioners, :fhir_patients,  :fhir_organizations, :fir_coverages, :fhir_locations, :patient_resources, :patient, :eob, :eobs 

  def load_fhir_eobs(patientid, eobid)
    puts "==>load_fhir_eobs Patient =#{patientid}" #" include=#{include}  filterbydate=#{filterbydate}"
    parameters = {}
    #     binding.pry 
    parameters[:_id] = eobid if eobid 

    parameters[:patient] = patientid 
  
    parameters[:"service-date"] = [] if start_date.present? || end_date.present?
    parameters[:"service-date"] << "ge#{DateTime.parse(start_date).strftime("%Y-%m-%d")}" if start_date.present?
    parameters[:"service-date"] << "le#{DateTime.parse(end_date).strftime("%Y-%m-%d")}" if end_date.present?

   
    includelist = ["ExplanationOfBenefit:patient", 
                   "ExplanationOfBenefit:care-team",
                   "ExplanationOfBenefit:coverage", 
                   "ExplanationOfBenefit:insurer", 
                   "ExplanationOfBenefit:provider"]
    parameters[:_include] = includelist
    # parameters[:_format] = "json"
    search = {parameters: parameters }
    results = @client.search(FHIR::ExplanationOfBenefit, search: search )
    #binding.pry

    capture_search_query(results)

    entries = results.resource.entry.map(&:resource)
    fhir_explanationofbenefits = entries.select {|entry| entry.resourceType == "ExplanationOfBenefit" }
    fhir_practitioners = entries.select {|entry| entry.resourceType == "Practitioner" }
    fhir_patients = entries.select {|entry| entry.resourceType == "Patient" }
    fhir_locations = entries.select {|entry| entry.resourceType == "Location" }
    fhir_organizations = entries.select {|entry| entry.resourceType == "Organization" }
    fhir_coverages = entries.select {|entry| entry.resourceType == "Coverage" }
    
    # HAPI FHIR Server is not currently supporting _include on either provider or coverage
    ##################### This is a temporary solution ####################
    
    # Get the provider references from all of the EOBs.
    eob_provider_references = fhir_explanationofbenefits.map(&:provider).map(&:reference)
    
    eob_provider_references.each do |reference|
      resource = @client.read(nil, reference).resource
      resource.resourceType == 'Organization' ? fhir_organizations << resource 
                                              : fhir_practitioners << resource
    
    end

    # Get the coverage references from all of the EOBs.
    eob_coverage_references = fhir_explanationofbenefits
                                .map(&:insurance)
                                .flatten
                                .map {|insurance| insurance.coverage.reference }
    
    eob_coverage_references.each do |reference|
      fhir_coverages << @client.read(nil, reference).resource
    end

    #######################################################################
    #temporary testing code
    #prov_refs = fhir_explanationofbenefits.map(&:provider)
    #binding.pry
    #fhir_explanationofbenefits.select {|ref| ref.resourceType == "ExplanationOfBenefit" }
    # HAPI FHIR Server is not currently supporting _include on either provider or coverage 
    # Need to figure out how to get the other resources.
    #provider_parameters = {}
    #provider_parameters[:_id] = "PractitionerDentalProvider1"

    #search = {parameters: provider_parameters }
    #results = @client.search(FHIR::Practitioner, search: search )
    #fhir_practitioners = [@client.read(FHIR::Practitioner, 'PractitionerDentalProvider1').resource]
    # get the provider references from all of the EOBs. There is a way to write this to continue in the case that one fails.
    #fhir_explanationofbenefits.map(&:provider).map(&:reference)
    #binding.pry
    #capture_search_query(results)
    #entries = results.resource.entry.map(&:resource)
    #fhir_practitioners = entries.select {|entry| entry.resourceType == "Practitioner" }
    #coverage_results = get_fhir_resources(@client, FHIR::Coverage, "Coverage1")
    #entries = coverage_results.resource.entry.map(&:resource)
    #fhir_coverages = entries.select {|entry| entry.resourceType == "Coverage" }

    #provider_results = get_fhir_resources(@client, FHIR::Practitioner, "PractitionerDentalProvider1")
    #entries = provider_results.resource.entry.map(&:resource)
    #fhir_practitioners = entries.select {|entry| entry.resourceType == "Practitioner" }




    patients = fhir_patients.map { |patient| Patient.new(patient) }
    @patient = patients[0] 
    practitioners = fhir_practitioners.map { |practitioner| Practitioner.new(practitioner) }
    locations = fhir_locations.map { |location| Location.new(location) }
    organizations = fhir_organizations.map { |organization| Organization.new(organization) }
    coverages = fhir_coverages.map { |coverage| Coverage.new(coverage, organizations) }
    explanationofbenefits = fhir_explanationofbenefits.map { |eob| EOB.new(eob, patients, practitioners, locations, organizations, coverages, practitionerroles) }.sort_by { |a|  -a.sortDate }
    @eobs = explanationofbenefits
  end

  # load_patient_resources:  Builds and executes a search for a given type restricted to a single patient and the appropriate profile      
  def load_patient_resources(type, profile, patientfield, pid, datefield=nil)
    parameters = {}
#        parameters[patientfield] = "Patient/" + pid
    parameters[patientfield] = pid
    parameters[:_profile] = profile if profile
#        parameters[:_count] = 1000 
    #     binding.pry 
    if datefield 
      parameters[datefield] = []
      parameters[datefield] << "ge"+ DateTime.parse(start_date).strftime("%Y-%m-%d")   if start_date.present?
      parameters[datefield] << "le"+ DateTime.parse(end_date).strftime("%Y-%m-%d")    if end_date.present?
    end
    search = { parameters: parameters }
    results = @client.search(type, search: search)
    results.resource.entry.map(&:resource)
  end

  # Get Fhir Resources:  Retrieves a referenced resource by ID, and optionally patientID
  def get_fhir_resources(fhir_client, type, resource_id, patient_id=nil)
    if patient_id == nil
        search = { parameters: {  _id: resource_id} } 
    else
        search = { parameters: {  _id: resource_id, patient: patient_id} }
    end
    results = fhir_client.search(type, search: search )
    #     binding.pry if results == nil || results.resource == nil || results.resource.entry == nil 
    results.resource.entry.map(&:resource)
  end
  
  def start_date
    params[:start_date] || session[:start_date]
  end 
  
  def end_date
    params[:end_date] || session[:end_date]
  end

  # Connect the FHIR client with the specified server and save the connection
  # for future requests.
  # If token is expired or within 10s of expiration, refresh the token

  def connect_to_server
    puts "==>connect_to_server"
    if session[:client_id].length == 0 
      @client = FHIR::Client.new(session[:iss_url])
      @client.use_r4
      return  # We do not have authentication
    end
    if session.empty? 
      err = "Session Expired"
      #     binding.pry 
      redirect_to root_path, alert: err
    end
    if session[:iss_url].present?
      @client = FHIR::Client.new(session[:iss_url])
      @client.use_r4
      token_expires_in = session[:token_expiration] - Time.now.to_i
      if token_expires_in.to_i < 10   # if we are less than 10s from an expiration, refresh
        get_new_token
      end
      @client.set_bearer_token(session[:access_token])
    end
  rescue StandardError => exception
    reset_session
    err = "Failed to connect: " + exception.message
    redirect_to root_path, alert: err
  end

  # Get a mew token from the authorization server
  def get_new_token
    auth = 'Basic ' + Base64.strict_encode64( session[:client_id] + ":" + session[:client_secret]).chomp
  
    rcResultJson = RestClient.post(
      session[:token_url],
      {
        grant_type: 'refresh_token', 
        refresh_token: session[:refresh_token], 
      },
      {
        :Authorization => auth
      }
    )
    rcResult = JSON.parse(rcResultJson)

    session[:patient_id] = rcResult["patient"]
    session[:access_token] = rcResult["access_token"]
    session[:refresh_token] = rcResult["refresh_token"]
    session[:token_expiration] = (Time.now.to_i + rcResult["expires_in"].to_i  )
  rescue StandardError => exception
    #     binding.pry 
    err = "Failed to refresh token: " + exception.message
    redirect_to root_path, alert: err
  end

  def capture_search_query(results)
    if results.present?
      # Prepare the query string for display on the page
      @search = "<Search String in Returned Bundle is empty>"
      @search = URI.decode(results.request[:url]) if results.request[:url].present?
    end
  end 

end

