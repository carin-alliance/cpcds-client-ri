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
    if params[:iss_url].length == 0
      params[:iss_url] = "http://localhost:8080/cpcds-server/fhir"
      params[:client_id] = "ed27a597-cfd5-4cbd-b4ed-1d213d5b38f2"
      params[:client_secret] = "a3gyqjMuNTsaDIATXmhBEOJTHY6dgY5FEAtTCUelT0yJVFfr8XgPqFSAqxKrOcrB3vgf4Xut9nV2rbnYn8XyEY7b8UPChJQGXa88954pJ34HAtUYfwVMUbIz47Wgr0CAWekcmeGL8PE2oKPcdJ4Bg150tBt4K53AQFrpf8dLo7X7cwjX4YINXosUCxWe2ojaKtjHD6a3jiRdhtPlY8uFdqtRsMV65pIFZUXVxY9yGvuf7op0ASNC2XrUGaJQqUOC"
    end 
    launch = params[:launch] || session[:launch] || "launch"
    iss = params[:iss_url] || session[:iss_url] 
    session[:client_id] = params[:client_id] || session[:client_id] 
    session[:client_secret] = params[:client_secret] || session[:client_secret]  
    # Get Server Metadata
    rcRequest = RestClient::Request.new(
      :method => :get,
      :url => iss + "/metadata",
     )
    rcResult = JSON.parse(rcRequest.execute)
    session[:auth_url] = rcResult["rest"][0]["security"]["extension"][0]["extension"].select{|e| e["url"] == "authorize"}[0]["valueUri"]
    session[:token_url] = rcResult["rest"][0]["security"]["extension"][0]["extension"].select{|e| e["url"] == "token"}[0]["valueUri"]
    session[:iss_url] = iss
    session[:launch] = launch


    # http://localhost:8180/authorization?response_type=code&redirect_uri=http://localhost:4000/login&aud=http://localhost:8080/cpcds-server/fhir&state=98wrghuwuogerg97&scope=launch patient/Patient.read openid fhirUser&client_id=0oa41ji88gUjAKHiE4x6

    redirect_to_auth_url = auth_url + 
      "?response_type=code"+
      "&redirect_uri="+ login_url +
      "&aud=" + iss +
      "&state=98wrghuwuogerg97" +
      "&scope=launch+patient%2FPatient.read+openid+fhirUser&" +
      "&client_id=" +  session[:client_id] 
    # binding.pry 
    redirect_to redirect_to_auth_url
  end


  def login
    session[:wakeupsession] = "ok" # using session hash prompts rails session to load
    session[:client_id] = params[:client_id] || session[:client_id] || "9e5cec3a-80f9-4d04-9851-9ce2106bb080"   # hard coded is for launch from logica sandbox
    session[:client_secret]  = params[:client_secret] || session[:client_secret]   
    code = params[:code]
    
     auth = 'Basic ' + Base64.strict_encode64( session[:client_id]  +":"+session[:client_secret]).chomp

   rcResult = JSON.parse(
      RestClient.post(
        session[:token_url],
       {
          grant_type: 'authorization_code', 
          code: code, 
          redirect_uri: "http://localhost:4000/login" ,
          client_id: "9e5cec3a-80f9-4d04-9851-9ce2106bb080"    # this is for a public, we need confidential using Authorization header
      },
      {
        :Authorization => auth
      }
      )
   )
    scope = rcResult["scope"]
    session[:access_token] = rcResult["access_token"]
    session[:refresh_token] = rcResult["refresh_token"]
    session[:patient_id] = rcResult["patient"]
    session[:token_expiration] = Time.now.to_i + rcResult["expires_in"].to_i
    @client = FHIR::Client.new(session[:iss_url])
    @client.use_r4
    @client.set_bearer_token(session[:access_token])

    # profile = 'http://hl7.org/fhir/us/carin/StructureDefinition/carin-bb-patient'
    # profile = 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient'
    #search = { parameters: { _profile: profile,  _id: patient_id}}
    search = { parameters: { _id: session[:patient_id]}}
    results = @client.search(FHIR::Patient, search: search )
    raise 'Serious Error -- retrieved patient has wrong ID'  unless patient_id == results.resource.entry[0].resource.id 

    redirect_to dashboard_url, notice: "signed in"

  rescue => exception
    puts "restful call failure"
    binding.pry
  end

end
