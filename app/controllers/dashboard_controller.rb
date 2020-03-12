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

  def index
    connect_to_server if @client == nil
    # profile = 'http://hl7.org/fhir/us/carin/StructureDefinition/carin-bb-patient'
    # profile = 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient'
    #search = { parameters: { _profile: profile,  _id: patient_id}}
    search = { parameters: { _id: patient_id}}
    results = @client.search(FHIR::Patient, search: search )
    @patient = Patient.new(results.resource.entry.map(&:resource)[0], @client)
  end

  def launch
    iss = params[:iss_url] || session[:iss_url]
    launch = params[:launch] || session[:launch] || "launch"
    client_id = params[:client_id] || session[:client_id]
    binding.pry 
    # Get Server Metadata
    rcRequest = RestClient::Request.new(
      :method => :get,
      :url => iss + "/metadata",
     )
    rcResult = JSON.parse(rcRequest.execute)
    auth_url = rcResult["rest"][0]["security"]["extension"][0]["extension"].select{|e| e["url"] == "authorize"}[0]["valueUri"]
    token_url = rcResult["rest"][0]["security"]["extension"][0]["extension"].select{|e| e["url"] == "token"}[0]["valueUri"]
    session[:auth_url] = auth_url
    session[:token_url] = token_url
    session[:iss_url] = iss
    session[:launch] = launch

    redirect_to_auth_url = auth_url + 
       "?client_id=" + client_id+
       "&launch="+launch+
       "&response_type=code"+
       "&redirect_uri="+ login_url +
       "&scope=launch+patient%2FPatient.read+openid+fhirUser&" +
       "&aud=" + iss +
       "&state=98wrghuwuogerg97"

    binding.pry 
    redirect_to redirect_to_auth_url
  end
  def login
    binding.pry 
    code = params[:code]
    
  #  auth = 'Basic ' + Base64.encode64( 'user:passwd' ).chomp

    session[:wakeupsession] = "ok" # using session hash prompts rails session to load
    token_url = session[:token_url]
    rcRequest = RestClient::Request.new(
      :method => :post,
      :url => token_url,
      :payload => {
        grant_type: 'authorization_code', 
        code: code, 
        redirect_uri: "http://localhost:4000/login" ,
        client_id: "9e5cec3a-80f9-4d04-9851-9ce2106bb080"
      }
    )
    rcResult = JSON.parse(rcRequest.execute)
    binding.pry 
    access_token = rcResult["access_token"]
    expires_in = rcResult["expires_in"]
    patient_id = rcResult["patient"]
    scope = rcResult["scope"]

    session[:access_token] = access_token
    session[:patient_id] = patient_id
    session[:token_expiration] = Time.now + expires_in.to_i
    binding.pry
    @client = FHIR::Client.new(iss_url)
    @client.use_r4
    @client.set_bearer_token(access_token)

    # profile = 'http://hl7.org/fhir/us/carin/StructureDefinition/carin-bb-patient'
    # profile = 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient'
    #search = { parameters: { _profile: profile,  _id: patient_id}}
    search = { parameters: { _id: patient_id}}
    results = @client.search(FHIR::Patient, search: search )
    raise 'Serious Error -- retrieved patient has wrong ID'  unless patient_id == results.resource.entry[0].resource.id 
    binding.pry
    redirect_to dashboard_url, notice: "signed in"

  rescue => exception
    puts "restful call failure"
    binding.pry
  end

end
