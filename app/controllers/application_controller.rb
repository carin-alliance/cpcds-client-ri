################################################################################
#
# Application Controller
#
# Copyright (c) 2020 The MITRE Corporation.  All rights reserved.
#
################################################################################

class ApplicationController < ActionController::Base
  rescue_from Rack::Timeout::RequestTimeoutException, with: :handle_timeout

  require "rest-client"
  require "json"
  include AuthHelper

  attr_accessor :explanationofbenefits, :practitioners, :patients, :locations, :organizations, :practitionerroles, :coverages, :resources
  attr_accessor :fhir_explanationofbenefits, :fhir_practitioners, :fhir_patients, :fhir_organizations, :fir_coverages, :fhir_locations, :patient_resources, :patient, :eob, :eobs

  def load_fhir_eobs(patientid, eobid = nil)
    puts "==>load_fhir_eobs Patient =#{patientid}" #" include=#{include}  filterbydate=#{filterbydate}"
    parameters = {}
    parameters[:_id] = eobid if eobid

    parameters[:patient] = patientid
    begin
      parameters[:"service-date"] = [] if start_date.present? || end_date.present?
      parameters[:"service-date"] << "ge#{DateTime.parse(start_date).strftime("%Y-%m-%d")}" if start_date.present?
      parameters[:"service-date"] << "le#{DateTime.parse(end_date).strftime("%Y-%m-%d")}" if end_date.present?
    rescue => exception
      redirect_back fallback_location: dashboard_path, alert: "Please provide a valid date in the form (dd/mm/yyyy)"
    end

    includelist = ["ExplanationOfBenefit:patient",
                   "ExplanationOfBenefit:care-team",
                   "ExplanationOfBenefit:coverage",
                   "ExplanationOfBenefit:insurer",
                   "ExplanationOfBenefit:provider"]
    parameters[:_include] = includelist
    # parameters[:_format] = "json"
    search = { parameters: parameters }
    results = @client.search(FHIR::ExplanationOfBenefit, search: search)
    if !(200..206).member?(results.response[:code])
      redirect_back fallback_location: dashboard_path, alert: "ERROR: #{results.response[:body]}" and return
    end

    capture_search_query(results)

    entries = results.resource.entry.map(&:resource)
    fhir_explanationofbenefits = entries.select { |entry| entry.resourceType == "ExplanationOfBenefit" }
    fhir_practitioners = entries.select { |entry| entry.resourceType == "Practitioner" }
    fhir_patients = entries.select { |entry| entry.resourceType == "Patient" }
    fhir_locations = entries.select { |entry| entry.resourceType == "Location" }
    fhir_organizations = entries.select { |entry| entry.resourceType == "Organization" }
    fhir_coverages = entries.select { |entry| entry.resourceType == "Coverage" }

    # HAPI FHIR Server is not currently supporting _include on either provider or coverage
    ##################### TODO: This is a temporary solution ####################

    # Get the provider references from all of the EOBs.
    eob_provider_references = fhir_explanationofbenefits.map(&:provider).map(&:reference)

    eob_provider_references.each do |reference|
      resource = @client.read(nil, reference).resource
      if resource.present?
        resource.resourceType == "Organization" ? fhir_organizations << resource : fhir_practitioners << resource
      end
    end

    # Get the coverage references from all of the EOBs.
    eob_coverage_references = fhir_explanationofbenefits
      .map(&:insurance)
      .flatten
      .map { |insurance| insurance.coverage.reference }

    eob_coverage_references.each do |reference|
      fhir_coverage = @client.read(nil, reference)&.resource
      fhir_coverages << fhir_coverage if fhir_coverage.present?
    end

    #######################################################################

    patients = fhir_patients.map { |patient| Patient.new(patient) }
    @patient = patients[0]
    practitioners = fhir_practitioners.map { |practitioner| Practitioner.new(practitioner) }
    locations = fhir_locations.map { |location| Location.new(location) }
    organizations = fhir_organizations.map { |organization| Organization.new(organization) }
    coverages = fhir_coverages.map { |coverage| Coverage.new(coverage, organizations) }
    explanationofbenefits = fhir_explanationofbenefits.map { |eob| EOB.new(@client, eob, patients, practitioners, locations, organizations, coverages, practitionerroles) }.sort_by { |a| -a.sortDate }
    @eobs = explanationofbenefits
  end

  # load_patient_resources:  Builds and executes a search for a given type restricted to a single patient and the appropriate profile
  def load_patient_resources(type, profile, patientfield, pid, datefield = nil)
    parameters = {}
    #        parameters[patientfield] = "Patient/" + pid
    parameters[patientfield] = pid
    parameters[:_profile] = profile if profile
    #        parameters[:_count] = 1000
    if datefield
      parameters[datefield] = []
      parameters[datefield] << "ge" + DateTime.parse(start_date).strftime("%Y-%m-%d") if start_date.present?
      parameters[datefield] << "le" + DateTime.parse(end_date).strftime("%Y-%m-%d") if end_date.present?
    end
    search = { parameters: parameters }
    results = @client.search(type, search: search)
    results.resource.entry.map(&:resource)
  end

  # Get Fhir Resources:  Retrieves a referenced resource by ID, and optionally patientID
  def get_fhir_resources(fhir_client, type, resource_id, patient_id = nil)
    if patient_id == nil
      search = { parameters: { _id: resource_id } }
    else
      search = { parameters: { _id: resource_id, patient: patient_id } }
    end
    results = fhir_client.search(type, search: search)
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

  def connect_to_server(code = nil)
    puts "==>connect_to_server"
    redirect_to home_path, alert: "Your session has expired. Please reconnect!" and return if (session.empty? || session[:iss_url].nil?)
    @client = session[:client]
    if @client.present?
      if !!session[:is_auth_server?]
        token_expires_in = session[:token_expiration] - Time.now.to_i
        if token_expires_in.to_i < 10 # if we are less than 10s from an expiration, refresh
          token = refresh_token()
          return if token.nil?
        end
        @client.set_bearer_token(session[:access_token])
      end
    else
      @client = FHIR::Client.new(session[:iss_url])
      @client.use_r4
      if !!session[:is_auth_server?]
        token = get_new_token(code)
        return if (token.nil? || session[:access_token].nil?)
        @client.set_bearer_token(session[:access_token])
        @client.default_json
      end
    end
    session[:client] = @client
  end

  # Get new token from the authorization server
  def get_new_token(code)
    auth = "Basic " + Base64.strict_encode64(session[:client_id] + ":" + session[:client_secret])
    begin
      result = RestClient.post(session[:token_url],
                               {
        grant_type: "authorization_code",
        code: code,
        #   _format: "json",
        redirect_uri: CLIENT_URL + "/login",
      },
                               {
        :Authorization => auth,
      })
    rescue StandardError => exception
      # reset_session
      redirect_to home_path, alert: "Failed to connect: " + exception.message and return
    end

    rcResult = JSON.parse(result)
    scope = rcResult["scope"]
    session[:access_token] = rcResult["access_token"]
    session[:refresh_token] = rcResult["refresh_token"]
    session[:token_expiration] = Time.now.to_i + rcResult["expires_in"].to_i
    session[:patient_id] = rcResult["patient"]
  rescue StandardError => exception
    redirect_to home_path, alert: "Failed to connect, please try again." and return
  end

  # Refresh token from the authorization server
  def refresh_token
    auth = "Basic " + Base64.strict_encode64(session[:client_id] + ":" + session[:client_secret]).chomp

    rcResultJson = RestClient.post(
      session[:token_url],
      {
        grant_type: "refresh_token",
        refresh_token: session[:refresh_token],
      },
      {
        :Authorization => auth,
      }
    )
    rcResult = JSON.parse(rcResultJson)

    session[:patient_id] = rcResult["patient"]
    session[:access_token] = rcResult["access_token"]
    session[:refresh_token] = rcResult["refresh_token"]
    session[:token_expiration] = (Time.now.to_i + rcResult["expires_in"].to_i)
  rescue StandardError => exception
    err = "Failed to refresh token: " + exception.message
    redirect_to home_path, alert: err and return
  end

  def capture_search_query(results)
    if results.present?
      # Prepare the query string for display on the page
      @search = "<Search String in Returned Bundle is empty>"
      @search = URI.decode(results.request[:url]) if results.request[:url].present?
    end
  end

  private
  # Handle time out request:
  def handle_timeout
    err = "No response from server: Timed out connecting to server. Server is either down or connection is slow."
    redirect_to home_path, alert: err
  end
end
