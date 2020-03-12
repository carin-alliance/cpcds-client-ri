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
  def iss_url
     session[:iss_url]
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


  # Connect the FHIR client with the specified server and save the connection
  # for future requests.

  def connect_to_server
    if iss_url.present?
      @client = FHIR::Client.new(iss_url)
      @client.use_r4
      @client.set_bearer_token(access_token)
    end
   rescue => exception
       err = "Connection failed: Ensure provided url points to a valid FHIR server"
       redirect_to root_path, flash: { error: err }
 
  end
end

