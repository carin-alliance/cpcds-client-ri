################################################################################
#
# Dashboard Controller
#
# Copyright (c) 2019 The MITRE Corporation.  All rights reserved.
#
################################################################################

class DashboardController < ApplicationController
  require 'rest-client'
  require 'json'
  require 'base64'
  before_action :establish_session_handler, only: [ :index, :show ]
  def index
  #   load_patient_specific_data_from_server
    # sets up @patient
    @patient = Patient.new(@fhir_patients[0], @resources, @client)
  end
  def login
    code = params[:code]
    encodedstate = params[:state]
    state = JSON.parse(Base64.decode64(encodedstate))
    password = state["password"]
    server_url = state["server_url"]
    auth_url = state["auth_url"]
    patient_id = state["patient_id"]
    auth = 'Basic ' + Base64.encode64( 'user:passwd' ).chomp
    redirect_uri = "http://localhost:4000/login"
    server_url = "http://localhost:8080/cpcds-server/fhir"
    session[:wakeupsession] = "ok" # using session hash prompts rails session to load
    puts "dashboard/login with session: " + session[:session_id]
    rcRequest = RestClient::Request.new(
      :method => :post,
      :url => "http://localhost:8180/token",
        :user => patient_id,
        :password => password,
      :payload => {
        grant_type: 'authorization_code', 
        code: code, 
        redirect_uri: redirect_uri 
      }
    )
    rcResult = JSON.parse(rcRequest.execute)
    access_token = rcResult["access_token"]
    expires_in = rcResult["expires_in"]
    server_url = "http://localhost:8080/cpcds-server/fhir"

    session[:access_token] = access_token
    token_expiration = Time.now + expires_in.to_i
  
    @client = FHIR::Client.new(server_url)
    @client.use_r4
    @client.set_bearer_token(access_token)

    # profile = 'http://hl7.org/fhir/us/carin/StructureDefinition/carin-bb-patient'
    profile = 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient'
    search = { parameters: { _profile: profile,  _id: patient_id}}
    results = @client.search(FHIR::Patient, search: search )
    raise 'Serious Error -- retrieved patient has wrong ID'  unless patient_id == results.resource.entry[0].resource.id 

    # At this point we have verified that:
    #   1) the userid/password combination can authenticate and yield a token
    #   2) the userid/password combination gives access for the right patient

    # Now we need to persist the token, the token validity time for retrieval by the original session using the
    # patient_key which is the patient_id with a timestamped suffix.
    binding.pry 
    session = Session.new do |s|
      s.patient_key = patient_key
      s.patient_id = patient_id
      s.token = access_token
      s.server_url = server_url
      s.auth_url = auth_url
      s.token_expiration = token_expiration
    end
    binding.pry 
    return

  rescue => exception
    puts "restful call failure"
    binding.pry
  end

end
