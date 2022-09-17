################################################################################
#
# Dashboard Controller
#
# Copyright (c) 2020 The MITRE Corporation.  All rights reserved.
#
################################################################################

# Most methods in this class come from application_controller and helpers/auth_helper.rb

# Smart on FHIR Launch sequence workflow controller
class DashboardController < ApplicationController
  require "rest-client"
  require "json"
  require "base64"

  def index
    connect_to_server() if @client.nil?
    puts "==>DashboardController.index"
  end

  # launch:  Pass either params or hardcoded server and client data to the auth_url via redirection
  def launch
    # Get a completely fresh session for each launch.  This is a rails method.
    reset_session
    cookies.clear
    redirect_to home_path, alert: "Please provide the server_url, client_id, and client_secret." and return if !all_credentials_provided?
    # Set auth sessions  with params values
    session[:launch] = params[:launch].present? ? params[:launch].strip : "launch"
    session[:iss_url] = cookies[:iss_url] = params[:iss_url].strip.delete_suffix("/").delete_suffix("/metadata")
    session[:client_id] = params[:client_id].strip
    session[:client_secret] = params[:client_secret].strip
    # Get the server metadata
    rcResult = get_server_metadata(session[:iss_url])
    redirect_to home_path, alert: rcResult and return if rcResult.class == String
    # Logic for authenticated access server
    if session[:is_auth_server?]
      begin
        server_auth_url = set_server_auth_url()
        redirect_to server_auth_url
      rescue StandardError => exception
        redirect_back fallback_location: home_path, alert: "Failed to connect: #{exception.message}" and return
      end
      # Logic for unauthenticated server access: the user will provide the patient ID in the client_id & client_secret fields.
    else
      session[:patient_id] = session[:client_secret]
      redirect_to dashboard_url, notice: "Signed in with Patient ID: #{session[:patient_id]}"
    end
    cookies.clear
  end

  # login:  Once authorization has happened, auth server redirects to here.
  #         Use the returned info to get a token
  #         Use the returned token and patientID to get the patient info
  def login
    if params[:error].present? # Authentication Failure
      err = "Authentication Failure: #{params[:error]} - #{params[:error_description]}"
      redirect_to home_path, alert: err
    else
      session[:wakeupsession] = "ok" # using session hash prompts rails session to load
      session[:client_id] = params[:client_id] || session[:client_id] #).gsub! /\t/, ''
      session[:client_secret] = params[:client_secret] || session[:client_secret] #).gsub! /\t/, ''
      code = params[:code]
      @client = connect_to_server(code)
      return if @client.nil?
      redirect_to eobs_url, notice: "Signed in with Patient ID: #{session[:patient_id]} "
    end
  end

  def disconnect
    reset_session
    cookies.clear
    redirect_to home_path, notice: "Server has been disconnected."
  end

  private

  def all_credentials_provided?
    params[:iss_url].present? && params[:client_id].present? && params[:client_secret].present?
  end
end
