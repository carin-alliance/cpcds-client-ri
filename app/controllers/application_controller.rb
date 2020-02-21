################################################################################
#
# Application Controller
#
# Copyright (c) 2019 The MITRE Corporation.  All rights reserved.
#
################################################################################

class ApplicationController < ActionController::Base
    before_action :establish_session_handler, only: [ :index, :show ]

    attr_accessor :explanationofbenefits, :practitioners, :patients, :locations, :organizations, :practitionerroles, :encounters, :fhir_encounters,
    :observations, :procedures, :immunizations, :diagnosticreports, :documentreferences, :claims, :conditions, :medicationrequests,
    :careteams, :careplans, :devices, :provenances, :resources
    attr_accessor :fhir_explanationofbenefits, 
    :fhir_practitioners, :fhir_patients, :fhir_locations, :fhir_organizations, :fhir_practitionerroles, :fhir_encounters, :fhir_encounters,
    :fhir_observations, :fhir_procedures, :fhir_immunizations, :fhir_diagnosticreports, :fhir_documentreferences, :fhir_claims, :fhir_conditions, :fhir_medicationrequests,
    :fhir_careteams, :fhir_careplans, :fhir_devices, :fhir_provenances, :patient_resources

        CPCDS_PATIENT_PROFILE_URL = 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient'
        CPCDS_ENCOUNTER_PROFILE_URL = 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-encounter'
        CPCDS_EOB_PROFILE_URL = 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/plannet-InsurancePlan'
        CPCDS_ENCOUNTER_PROFILE_URL = 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/plannet-Network'
        CPCDS_PRACTITIONER_PROFILE_URL = 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/plannet-Practitioner'
        CPCDS_ORGANIZATION_PROFILE_URL = 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/plannet-PractitionerRole'
             


    def load_patient_specific_data_from_server
        # read all patient data from server
        pid = session[:patient_id]
        binding.pry if pid == nil 
        @fhir_procedures = @fhir_procedures || load_patient_resources(FHIR::Procedure, nil, :subject, pid )
        @fhir_encounters = @fhir_encounters || load_patient_resources(FHIR::Encounter, nil, :subject, pid )
        @fhir_claims = @fhir_claims || load_patient_resources(FHIR::Claim, nil, :patient, pid )
        @fhir_explanationofbenefits = @fhir_explanationofbenefits || load_patient_resources(FHIR::ExplanationOfBenefit, nil, :patient, pid )
        @fhir_observations = @fhir_observations || load_patient_resources(FHIR::Observation, nil, :subject, pid )
        @fhir_immunizations = @fhir_immunizations || load_patient_resources(FHIR::Immunization, nil, :patient, pid )
        @fhir_conditions = @fhir_conditions || load_patient_resources(FHIR::Condition, nil, :subject, pid )
        @fhir_diagnosticreports = @fhir_diagnosticreports || load_patient_resources(FHIR::DiagnosticReport, nil, :subject, pid )
        @fhir_medicationrequests = @fhir_medicationrequests || load_patient_resources(FHIR::MedicationRequest, nil, :subject, pid )
        @fhir_careteams = @fhir_careteams || load_patient_resources(FHIR::CareTeam, nil, :subject, pid )
        @fhir_devices = @fhir_careteams || load_patient_resources(FHIR::Device, nil, :subject, pid )
        binding.pry 
        #@locations = nil # ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::Location }.map(&:resource)
        #@organizations = nil # ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::Organization }.map(&:resource)
        #@practitioners nil # ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::Practitioner }.map(&:resource)
        #@practitionerroles nil # ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::PractitionerRole }.map(&:resource)
      @resources = {
         :patient => @fhir_patients,
  #      :locations => @locations,
  #      :organizations => @organizations,
  #      :practitioners => @practitioners,
  #      :practitionerroles => @practitionerroles,
        :encounters => @fhir_encounters,
        :observations => @fhir_observations,
        :procedures => @fhir_procedures,
        :immunizations => @fhir_immunizations,
        :diagnosticreports => @fhir_diagnosticreports,
        :documentreferences => @fhir_documentreferences,
        :claims => @fhir_claims,
        :observations => @fhir_observations,
        :explanationofbenefits => @fhir_explanationofbenefits,
        :conditions => @fhir_conditions,
        :medicationrequests => @fhir_medicationrequests,
        :careteams => @fhir_careteams,
        :careplans => @fhir_careplans,
        :devices => @fhir_devices,
        }
       end
    
       def load_patient_resources (type, profile, field, pid)
        parameters = {}
        parameters[field] = "Patient/" + pid
        parameters[:_profile] = profile if profile
        parameters[:_count] = 1000 
        search = {parameters: parameters }
        results = @client.search(type, search: search )
        results.resource.entry.map(&:resource)
       end

       
    def load_bundle
    # read a bundle from a file
    file = File.read('../cpcds-server-ri/CPCDS_patient_data/Darin74_Olson653.json')
    @bundle = FHIR::Json.from_json(file)
    @bundleCountsByType = @bundle.entry.map { | entry | entry.resource.resourceType}.group_by{|e| e}.map{|k, v| [k, v.length]}.to_h
    @patients ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::Patient }.map(&:resource)
    @locations ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::Location }.map(&:resource)
    @organizations ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::Organization }.map(&:resource)
    @practitioners ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::Practitioner }.map(&:resource)
    @practitionerroles ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::PractitionerRole }.map(&:resource)
    @encounters ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::Encounter }.map(&:resource)
    @observations ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::Observation }.map(&:resource)
    @procedures ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::Procedure }.map(&:resource)
    @immunizations ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::Immunization }.map(&:resource)
    @diagnosticreports ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::DiagnosticReport }.map(&:resource)
    @documentreferences ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::DocumentReference }.map(&:resource)
    @claims ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::Claim }.map(&:resource)
    @explanationofbenefits ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::ExplanationOfBenefit }.map(&:resource)
    @conditions ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::Condition }.map(&:resource)
    @medicationrequests ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::MedicationRequest }.map(&:resource)
    @careteams ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::CareTeam }.map(&:resource)
    @careplans ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::CarePlan }.map(&:resource)
    @devices ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::Device }.map(&:resource)
    @provenances ||= @bundle.entry.select { |entry| entry.resource.instance_of? FHIR::Provenance }.map(&:resource)
    @resources = {
    :patients => @patients,
    :locations => @locations,
    :organizations => @organizations,
    :practitioners => @practitioners,
    :practitionerroles => @practitionerroles,
    :encounters => @encounters,
    :observations => @observations,
    :procedures => @procedures,
    :immunizations => @immunizations,
    :diagnosticreports => @diagnosticreports,
    :documentreferences => @documentreferences,
    :claims => @claims,
    :explanationofbenefits => @explanationofbenefits,
    :conditions => @conditions,
    :medicationrequests => @medicationrequests,
    :careteams => @careteams,
    :careplans => @careplans,
    :devices => @devices,
    :provenances => @provenances
    }
   end

    def getPractitioner(id)
        practitioners.select{|p| p.id==cleanup(id)}
    end
    def getClaim(id)
        claims.select{|p| p.id==cleanup(id)}
    end
    def getProcedure(id)
        procedures.select{|p| p.id==cleanup(id)}
    end
    def getEncounter(id)
        encounters.select{|p| p.id==cleanup(id)}
    end

     def cleanup(id)
        id.gsub("urn:uuid:", "")
     end
# Get the FHIR server url
def server_url
    params[:server_url] || session[:server_url]
  end
  def patient_id
    params[:patient_id] || session[:patient_id]
  end
  def patient_key
    params[:patient_key] || session[:patient_key]
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
    if server_url.present? && patient_id.present? && patient_key.present?
      session[:wakeupsession] = "ok" # using session hash prompts rails session to load
      #SessionHandler.establish(session.id, params[:server_url])
       binding.pry 
    else 
        err = "Please enter a FHIR server address, a valid patient ID, and a valid patient key."
        binding.pry 
        cookies[:session_url] = nil
        session[:patient_key] = nil
        cookies[:patient_id] = nil
        session[:patient_id] = nil
        redirect_to root_path, flash: { error: err }
        return
    end 
      @client = FHIR::Client.new(server_url)
      @client.use_r4
      @client.set_bearer_token(patient_key)

      # profile = 'http://hl7.org/fhir/us/carin/StructureDefinition/carin-bb-patient'
      profile = 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient'
      search = { parameters: { _profile: profile,  _id: patient_id}, created: "ge2016-01-01"}
      results = @client.search(FHIR::Patient, search: search )
      binding.pry
      raise 'Serious Error -- retrieved patient has wrong ID'  unless patient_id == results.resource.entry[0].resource.id 
      @fhir_patients = results.resource.entry.map(&:resource)
      cookies[:patient_key] = patient_key
      session[:patient_key] = patient_key
      cookies[:patient_id] = patient_id
      session[:patient_id] = patient_id 
      cookies[:server_url] = server_url
      session[:server_url] = server_url 
     
    end
end
