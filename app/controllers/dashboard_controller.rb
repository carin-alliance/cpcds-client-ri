################################################################################
#
# Dashboard Controller
#
# Copyright (c) 2020 The MITRE Corporation.  All rights reserved.
#
################################################################################

class DashboardController < ApplicationController
  require 'rest-client'
  require 'json'
  require 'base64'

  def index
    connect_to_server if @client == nil
 
    puts "==>DashboardController.index"
    

  end

  # launch:  Pass either params or hardcoded server and client data to the auth_url via redirection
  def launch
    #reset_session    # Get a completely fresh session for each launch.  This is a rails method.
   
    if params[:client_id].length == 0   #this is a sentinel for unauthenticated access with the patient ID in the client_secret
      session[:client_secret] = session[:patient_id] = params[:client_secret]
      session[:client_id] = params[:client_id]
      session[:iss_url]  = params[:iss_url]
      @client = FHIR::Client.new(session[:iss_url])
      @client.use_r4
      # @client.set_bearer_token(session[:access_token])
      puts "==>redirect_to #{dashboard_url}"
      redirect_to root_url, alert: "Please provide a client id and secret"
    else
      # Let Params values over-ride session values if they are present
      launch = params[:launch] || session[:launch] || "launch"
      iss = (params[:iss_url] || session[:iss_url] ).delete_suffix("/metadata")
      session[:client_id] = params[:client_id] || session[:client_id] 
      session[:client_secret] = params[:client_secret] || session[:client_secret]  

      session[:client_id]
      session[:client_secret]

      # Get Server Metadata
      rcRequest = RestClient::Request.new(
        :method => :get,
        :url => iss + "/metadata"
      )

      rcResult = JSON.parse(rcRequest.execute)
      session[:auth_url] = rcResult["rest"][0]["security"]["extension"][0]["extension"].select{|e| e["url"] == "authorize"}[0]["valueUri"]
      session[:token_url] = rcResult["rest"][0]["security"]["extension"][0]["extension"].select{|e| e["url"] == "token"}[0]["valueUri"]
      session[:iss_url] = iss
      session[:launch] = launch
      
      redirect_to_auth_url = auth_url + 
        "?response_type=code"+
        "&redirect_uri="+ login_url +
        "&aud=" + iss +
        "&state=98wrghuwuogerg97" +
        "&scope=launch+patient%2FPatient.read+openid+fhirUser&" +
        "&client_id=" +  session[:client_id] +
        "&_format=json"
        puts "===>redirect to #{redirect_to_auth_url}"
      redirect_to redirect_to_auth_url
    end 
  end


  # login:  Once authorization has happened, auth server redirects to here.   
  #         Use the returned info to get a token  
  #         Use the returned token and patientID to get the patient info
  def login
    if params[:error].present?   # Authentication Failure
      ## binding.pry 
      err = "Authentication Failure: " + params[:error] + " - " + params[:error_description]
      redirect_to root_path, alert: err
    else
      session[:wakeupsession] = "ok" # using session hash prompts rails session to load
      session[:client_id] = (params[:client_id] || session[:client_id])
      session[:client_secret] = params[:client_secret].gsub! /\t/, '' unless params[:client_secret].nil?
      code = params[:code]
      auth = 'Basic ' + Base64.strict_encode64( session[:client_id] + ":" + session[:client_secret])

      result = RestClient.post(
        session[:token_url],
        {
            grant_type: "authorization_code", 
            code: code, 
         #   _format: "json",
            redirect_uri: CLIENT_URL + "/login" 
        },
        {
          :Authorization => auth
        }
      )

      rcResult = JSON.parse(result)
      scope = rcResult["scope"]
      session[:access_token] = rcResult["access_token"]
      session[:refresh_token] = rcResult["refresh_token"]
      @patient = session[:patient_id] = rcResult["patient"]
      session[:token_expiration] = Time.now.to_i + rcResult["expires_in"].to_i
      @client = FHIR::Client.new(session[:iss_url])
      @client.use_r4
      @client.set_bearer_token(session[:access_token])
      @client.default_json
      redirect_to dashboard_url, notice: "Signed in"
    end
  end

end
