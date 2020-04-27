################################################################################
#
# Application Controller
#
# Copyright (c) 2019 The MITRE Corporation.  All rights reserved.
#
################################################################################

class ApplicationController < ActionController::Base
    require 'rest-client'
    require 'json'

    attr_accessor :explanationofbenefits, :practitioners, :patients, :locations, :organizations, :practitionerroles, :encounters, :fhir_encounters,
    :observations, :procedures, :immunizations, :diagnosticreports, :documentreferences, :claims, :conditions, :medicationrequests,
    :careteams, :careplans, :devices, :provenances, :resources
    attr_accessor :fhir_explanationofbenefits, :fhir_claims, :fhir_practitioners, :fhir_patients,  :fhir_organizations, :fhir_practitionerroles, :patient_resources

  # load_patient_resources:  Builds and executes a search for a given type restricted to a single patient and the appropriate profile      
       def load_patient_resources (type, profile, patientfield, pid, datefield=nil)
        parameters = {}
        parameters[patientfield] = "Patient/" + pid
        parameters[:_profile] = profile if profile
        parameters[:_count] = 1000 
 
        if datefield 
            parameters[datefield] = []
            parameters[datefield] << "ge"+ DateTime.parse(start_date).strftime("%Y-%m-%d")   if start_date.present?
            parameters[datefield] << "le"+ DateTime.parse(end_date).strftime("%Y-%m-%d")    if end_date.present?
        end
        search = {parameters: parameters }
        results = @client.search(type, search: search )
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
        binding.pry if results == nil || results.resource == nil || results.resource.entry == nil 
        results.resource.entry.map(&:resource)
      end
  
   
  # Utility accessors that reference session data
  def iss_url
     session[:iss_url]
  end
  def client_id
    session[:client_id]
  end

 def client_secret
    session[:client_secret]
 end

  def auth_url
      session[:auth_url]
  end

  def patient_id
     session[:patient_id]
  end
  def start_date
    params[:start_date] || session[:start_date]
  end 
  
  def end_date
    params[:end_date] || session[:end_date]
  end
  def access_token
        session[:access_token]
  end
  def refresh_token
    session[:refresh_token]
  end
  def token_expiration
    session[:token_expiration]
  end


  # Connect the FHIR client with the specified server and save the connection
  # for future requests.
  # If token is expired or within 10s of expiration, refresh the token

  def connect_to_server
    if session.empty? 
      err = "Session Expired"
      binding.pry 
      redirect_to root_path, flash: { error: err }
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
   rescue => exception
       err = "Connection failed: Ensure provided url points to a valid FHIR server"
       redirect_to root_path, flash: { error: err }
  end

  # Get a mew token from the authorization server
  def get_new_token
    binding.pry 
    auth = 'Basic ' + Base64.strict_encode64( session[:client_id] +":"+session[:client_secret]).chomp
  
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
      session[:token_expiration] = Time.now.to_i + rcResult["expires_in"].to_i  
    rescue => exception
        binding.pry 
        err = "Failed to refresh token"
        redirect_to root_path, flash: { error: err }
  end


end

