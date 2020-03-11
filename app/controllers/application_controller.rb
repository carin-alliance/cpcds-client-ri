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
    
        CPCDS_PATIENT_PROFILE_URL = 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient'
        CPCDS_ENCOUNTER_PROFILE_URL = 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-encounter'
        CPCDS_EOB_PROFILE_URL = 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/plannet-InsurancePlan'
        CPCDS_ENCOUNTER_PROFILE_URL = 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/plannet-Network'
        CPCDS_PRACTITIONER_PROFILE_URL = 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/plannet-Practitioner'
        CPCDS_ORGANIZATION_PROFILE_URL = 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/plannet-PractitionerRole'
             


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

       def get_fhir_resources(fhir_client, type, resource_id)
        search = { parameters: {  _id: resource_id} }
        results = fhir_client.search(type, search: search )
        results.resource.entry.map(&:resource)
      end
  
   
  # Get the FHIR server url
def server_url
    params[:server_url] || session[:server_url]
  end
  def auth_url
    params[:auth_url] || session[:auth_url]
  end

  def patient_id
    params[:patient_id] || session[:patient_id]
  end
  def password
    params[:password] || session[:password]
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


  # Connect the FHIR client with the specified server and save the connection
  # for future requests.

  def connect_to_server
    if server_url.present?
      @client = FHIR::Client.new(server_url)
      @client.use_r4
      @client.additional_headers = { 'Accept-Encoding' => 'identity' }  # 
      cookies[:server_url] = server_url
      session[:server_url] = server_url      
     end
   rescue => exception
       err = "Connection failed: Ensure provided url points to a valid FHIR server"
       redirect_to root_path, flash: { error: err }
 
  end
#-----------------------------------------------------------------------------
  private
  #-----------------------------------------------------------------------------
  
  def establish_session_handler
    binding.pry 
    return if  session[:access_token]  && session_url.present?  
    if server_url.present? && patient_id.present? && auth_url.present? && password.present? 
      session[:wakeupsession] = "ok" # using session hash prompts rails session to load
      #SessionHandler.establish(session.id, params[:server_url])
      # Try to connect to authenticatiorcn server


      puts "establish_session_handler with session: " + session[:session_id]
      client = FHIR::Client.new(server_url)
      
      session[:patient_id] = patient_id
      session[:server_url] = server_url 
      authurl = auth_url + "/authorization"
      patient_key =  patient_id + (Time.now.to_i%100000).to_s   # Each attempt for a given patient gets a different key
      session[:patient_key] = patient_key
      statecontent = {
          "patient_id"=> patient_id,
          "patient_key" => patient_key,
          "server_url" => server_url,
          "auth_url" => auth_url,
          "password" => password
      }
      state = Base64.encode64(JSON.generate(statecontent))
      binding.pry 
      rcRequest = RestClient::Request.new(
        :url => authurl,
        :method => :get,
        :headers => {
           :params => {
            :max_redirects => 0,
            :response_type => 'code',
             :client_id => patient_id,
             :state => state,
             :scope => 'patient/*.read',
             :aud => server_url,
             :redirect_uri => 'http://localhost:4000/login'      
            }
        }
      )
      begin 
        rcRequest.execute
      rescue => error
        p error 
        binding.pry 
      end
       return 
    else 
        err = "Please enter a FHIR server address, an authorization server address, a valid patient ID, and a valid password."
        cookies[:session_url] = nil
        cookies[:auth_url] = nil
        session[:session_url] = nil
        session[:auth_url] = nil
        session[:patient_id] = nil
        cookies[:patient_id] = nil
        session[:password] = nil
        cookies[:password] = nil
        redirect_to root_path, flash: { error: err }
        return
    end 
     end
   rescue => exception
       binding.pry 
end
